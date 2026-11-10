require File.expand_path('../../spec_helper', __FILE__)
require 'open3'

module ProjectSpecs
  describe Xcodeproj::Project::JSONFormat do
    extend SpecHelper::TemporaryDirectory

    before do
      FileUtils.cp_r(fixture_path('JSONProject', 'App.xcodeproj'), temporary_directory)
      @path = temporary_directory + 'App.xcodeproj'
      @converted_pbxproj = fixture_path('JSONProject', 'App.pbxproj')
    end

    # Stubs `xcodebuild -convert-project` for one format. The block runs in
    # place of the conversion and receives the path of the temporary project
    # that xcodebuild would convert.
    #
    def stub_conversion(format_name, success = true)
      Open3.stubs(:capture2e).with do |*arguments|
        next false unless arguments[0, 4] == ['xcodebuild', '-convert-project', format_name, '-project']
        yield Pathname(arguments[4]) if block_given?
        true
      end.returns(['xcodebuild output', stub(:success? => success)])
    end

    # Stubs the conversion that opening a project runs, so that it produces
    # the `project.pbxproj` that Xcode converts the fixture to.
    #
    def stub_conversion_to_pbxproj
      stub_conversion('Xcode 27.0') do |project_path|
        FileUtils.cp(@converted_pbxproj, project_path + 'project.pbxproj')
      end
    end

    it 'opens a project by converting a temporary copy of project.xcproj next to the project with xcodebuild' do
      converted_project_path = nil
      stub_conversion('Xcode 27.0') do |project_path|
        converted_project_path = project_path
        (project_path + 'project.xcproj').read.should == (@path + 'project.xcproj').read
        FileUtils.cp(@converted_pbxproj, project_path + 'project.pbxproj')
      end

      project = Xcodeproj::Project.open(@path)

      converted_project_path.should.not == @path
      converted_project_path.dirname.should == @path.dirname
      Pathname.glob(temporary_directory + '*.xcodeproj', File::FNM_DOTMATCH).should == [@path]
      project.targets.map(&:name).should == %w(App AppTests)
      versions = project.targets.first.build_configurations.map { |c| [c.name, c.build_settings['MARKETING_VERSION']] }
      versions.should == [%w(Debug 1.0), %w(Release 1.1)]
      (@path + 'project.pbxproj').should.not.exist
    end

    it 'reads the attributes that Xcode writes differently when it converts a project' do
      stub_conversion_to_pbxproj

      target = Xcodeproj::Project.open(@path).targets.first

      copy_files_phase = target.copy_files_build_phases.first
      copy_files_phase.dst_subfolder.should == 'Frameworks'
      copy_files_phase.dst_subfolder_spec.should.be.nil
      copy_files_phase.symbol_dst_subfolder_spec.should == :frameworks
      target.build_rules.first.script.lines.map(&:chomp).should ==
        ['echo "generate $INPUT_FILE_NAME"', 'cp "$INPUT_FILE_PATH" "$DERIVED_FILE_DIR/$INPUT_FILE_BASE.swift"']
      target.shell_script_build_phases.first.shell_script.should == 'echo "build $CURRENT_PROJECT_VERSION"'
    end

    it 'converts the copy in the system temporary directory when the project directory is not writable' do
      File.stubs(:writable?).returns(true)
      File.stubs(:writable?).with(@path.dirname.to_s).returns(false)
      converted_project_path = nil
      stub_conversion('Xcode 27.0') do |project_path|
        converted_project_path = project_path
        FileUtils.cp(@converted_pbxproj, project_path + 'project.pbxproj')
      end

      Xcodeproj::Project.open(@path)

      converted_project_path.dirname.should == Pathname(Dir.tmpdir)
    end

    it 'saves a project by converting a temporary project.pbxproj to project.xcproj with xcodebuild' do
      stub_conversion_to_pbxproj
      project = Xcodeproj::Project.open(@path)
      project.targets.first.build_configurations.each { |c| c.build_settings['CURRENT_PROJECT_VERSION'] = '42' }
      written_pbxproj = nil
      stub_conversion('Xcode Project') do |project_path|
        written_pbxproj = (project_path + 'project.pbxproj').read
        File.write(project_path + 'project.xcproj', 'converted project')
      end

      project.save

      written_pbxproj.should.include 'CURRENT_PROJECT_VERSION = 42;'
      (@path + 'project.xcproj').read.should == 'converted project'
      (@path + 'project.pbxproj').should.not.exist
    end

    it 'saves a project to another path in the format it was opened from' do
      stub_conversion_to_pbxproj
      project = Xcodeproj::Project.open(@path)
      stub_conversion('Xcode Project') do |project_path|
        File.write(project_path + 'project.xcproj', 'converted project')
      end
      copy_path = temporary_directory + 'Copy.xcodeproj'

      project.save(copy_path)

      (copy_path + 'project.xcproj').read.should == 'converted project'
      (copy_path + 'project.pbxproj').should.not.exist
    end

    it 'deletes project.pbxproj at the save path when it saves a JSON format project' do
      stub_conversion_to_pbxproj
      project = Xcodeproj::Project.open(@path)
      stub_conversion('Xcode Project') do |project_path|
        File.write(project_path + 'project.xcproj', 'converted project')
      end
      copy_path = temporary_directory + 'Copy.xcodeproj'
      copy_path.mkpath
      FileUtils.cp(@converted_pbxproj, copy_path + 'project.pbxproj')

      project.save(copy_path)

      (copy_path + 'project.xcproj').should.exist
      (copy_path + 'project.pbxproj').should.not.exist
    end

    it 'deletes project.xcproj at the save path when it saves a plist format project' do
      project = Xcodeproj::Project.new(temporary_directory + 'Plist.xcodeproj')

      project.save(@path)

      (@path + 'project.pbxproj').should.exist
      (@path + 'project.xcproj').should.not.exist
    end

    it 'keeps project.xcproj and stays dirty when the conversion fails while saving' do
      stub_conversion_to_pbxproj
      project = Xcodeproj::Project.open(@path)
      project.mark_dirty!
      original = (@path + 'project.xcproj').read
      stub_conversion('Xcode Project', false)

      should.raise(Xcodeproj::Informative) { project.save }
      (@path + 'project.xcproj').read.should == original
      project.should.be.dirty
    end

    it 'raises an informative error when xcodebuild cannot convert the project' do
      stub_conversion('Xcode 27.0', false)

      error = should.raise(Xcodeproj::Informative) { Xcodeproj::Project.open(@path) }
      error.message.should.include 'Xcode 27.2 or later'
      error.message.should.include 'xcodebuild output'
    end

    it 'leaves out the usage text that an xcodebuild without -convert-project prints after the error' do
      output = "xcodebuild: error: invalid option '-convert-project'\n\nUsage: xcodebuild [-project <projectname>]\n"
      Open3.stubs(:capture2e).returns([output, stub(:success? => false)])

      error = should.raise(Xcodeproj::Informative) { Xcodeproj::Project.open(@path) }
      error.message.should.include "invalid option '-convert-project'"
      error.message.should.not.include 'Usage: xcodebuild'
    end

    it 'raises an informative error when xcodebuild is not installed' do
      Open3.stubs(:capture2e).raises(Errno::ENOENT, 'xcodebuild')

      error = should.raise(Xcodeproj::Informative) { Xcodeproj::Project.open(@path) }
      error.message.should.include 'Xcode 27.2 or later'
    end

    it 'raises an informative error when a project contains both project files' do
      FileUtils.cp(@converted_pbxproj, @path + 'project.pbxproj')

      error = should.raise(Xcodeproj::Informative) { Xcodeproj::Project.open(@path) }
      error.message.should.include 'contains both `project.pbxproj` and `project.xcproj`'
    end

    xcode_version = begin
      Open3.capture2e('xcodebuild', '-version').first[/^Xcode (\S+)/, 1]
    rescue SystemCallError
      nil
    end

    # These specs run the real conversion, so they only run with Xcode 27.2 or later.
    if xcode_version && Gem::Version.new(xcode_version) >= Gem::Version.new('27.2')
      it 'opens and saves a project without changing project.xcproj' do
        original = (@path + 'project.xcproj').read

        Xcodeproj::Project.open(@path).save

        (@path + 'project.xcproj').read.should == original
      end

      it 'saves a build setting change as a single added line in project.xcproj' do
        original = (@path + 'project.xcproj').read
        project = Xcodeproj::Project.open(@path)
        project.targets.first.build_configurations.each { |c| c.build_settings['CURRENT_PROJECT_VERSION'] = '42' }

        project.save

        saved = (@path + 'project.xcproj').read
        (saved.lines - original.lines).map(&:strip).should == ['"CURRENT_PROJECT_VERSION": "42",']
        (original.lines - saved.lines).should.be.empty
      end
    end
  end
end
