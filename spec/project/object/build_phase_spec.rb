require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe AbstractBuildPhase do
    before do
      # Can't initialize AbstractBuildPhase directly
      @build_phase = @project.new(PBXCopyFilesBuildPhase)
    end

    #----------------------------------------#

    describe '#add_file_reference' do
      it 'can add a file reference to its build files' do
        file = @project.new_file('some/file')
        @build_phase.add_file_reference(file)
        @build_phase.files_references.should.include(file)
      end

      it 'can prevent duplicates while adding a file reference' do
        file = @project.new_file('some/file')
        @build_phase.add_file_reference(file, true)
        @build_phase.add_file_reference(file, true)
        @build_phase.files_references.should == [file]
      end
    end

    #----------------------------------------#

    describe '#sort' do
      it 'sorts file references by name' do
        files = %w(b a d c)
        files.each do |filename|
          file = @project.new_file(filename)
          @build_phase.add_file_reference(file)
        end
        @build_phase.sort
        @build_phase.files_references.map(&:path).should == %w(a b c d)
      end

      it 'sorts file references by full name if ambiguous' do
        files = %w(f.b f.a f.d f.c)
        files.each do |filename|
          file = @project.new_file(filename)
          @build_phase.add_file_reference(file)
        end
        @build_phase.sort
        @build_phase.files_references.map(&:path).should == %w(f.a f.b f.c f.d)
      end

      it 'sorts file references by file paths if ambiguous' do
        files = %w(
          zh-Hant.lproj/InfoPlist.strings
          he.lproj/InfoPlist.strings
          ar.lproj/InfoPlist.strings
          en.lproj/InfoPlist.strings
          el.lproj/InfoPlist.strings
        )

        files.each do |filename|
          file = @project.new_file(filename)
          @build_phase.add_file_reference(file)
        end
        @build_phase.sort
        @build_phase.files_references.map(&:path).should == %w(
          ar.lproj/InfoPlist.strings
          el.lproj/InfoPlist.strings
          en.lproj/InfoPlist.strings
          he.lproj/InfoPlist.strings
          zh-Hant.lproj/InfoPlist.strings
        )
      end

      it 'sorts file references by full file paths' do
        groups = %w(b a d c)

        parent_group = @project.new_group('parent', 'parent')

        groups.each do |group_name|
          group = parent_group.new_group(group_name, group_name)
          file = group.new_file('file.json')
          @build_phase.add_file_reference(file)
        end
        @build_phase.sort
        @build_phase.files_references.map(&:full_path).map(&:to_s).should == %w(
          parent/a/file.json
          parent/b/file.json
          parent/c/file.json
          parent/d/file.json
        )
      end
    end

    #----------------------------------------#

    it "returns the files it's associated with through its build files" do
      file = @project.new_file('some/file')
      @build_phase.add_file_reference(file)
      @build_phase.files_references.should == [file]
    end

    it 'returns the display names of the build files' do
      @build_phase.add_file_reference(@project.new_file('file_1'))
      @build_phase.add_file_reference(@project.new_file('file_2'))
      @build_phase.file_display_names.should == %w(file_1 file_2)
    end

    it 'returns whether it includes the given build file' do
      f1 = @project.new_file('file_1')
      build_file = @build_phase.add_file_reference(f1)
      @build_phase.build_file(f1).should == build_file
    end

    it 'returns whether it includes the given build file' do
      f1 = @project.new_file('file_1')
      f2 = @project.new_file('file_2')
      @build_phase.add_file_reference(f1)
      @build_phase.should.include?(f1)
      @build_phase.should.not.include?(f2)
    end

    it 'updates build files of a file' do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      file = @project.new_file('Ruby.m')
      @target.source_build_phase.add_file_reference(file)
      @target.source_build_phase.files.count.should == 1
      file.build_files.count.should == 1
      file.build_files.first.file_ref.should == file
    end

    it 'removes a build file' do
      file = @project.new_file('Ruby.m')
      build_file = @build_phase.add_file_reference(file)
      file.build_files.count.should == 1
      @build_phase.files.count.should == 1

      @build_phase.remove_file_reference(file)
      file.build_files.count.should == 0
      @build_phase.files.count.should == 0
      @project.objects.find { |obj| obj == build_file }.should.nil?
    end

    it 'removes all the build files from a phase' do
      files = []
      3.times do |i|
        file = @project.new_file("file #{i}")
        files << file
        @build_phase.add_file_reference(file)
        file.referrers.count.should == 2
      end
      @build_phase.files.count.should == 3
      @build_phase.clear_build_files
      @build_phase.files.count.should == 0
      files.each { |f| f.referrers.count.should == 1 }
    end

    it 'concrete implementations subclass it' do
      concrete_classes = [
        PBXHeadersBuildPhase,
        PBXSourcesBuildPhase,
        PBXFrameworksBuildPhase,
        PBXResourcesBuildPhase,
        PBXCopyFilesBuildPhase,
        PBXShellScriptBuildPhase,
      ]
      concrete_classes.each do |klass|
        (klass < AbstractBuildPhase).should.be.true
      end
    end

    it 'does not raise an exception when removing a file that is not in the build phase' do
      file = @project.main_group.new_file('test.png')
      lambda { @build_phase.remove_file_reference(file) }.should.not.raise(NoMethodError)
    end
  end

  describe PBXCopyFilesBuildPhase do
    before do
      @build_phase = @project.new(PBXCopyFilesBuildPhase)
    end

    it 'is a AbstractBuildPhase' do
      @build_phase.should.be.kind_of AbstractBuildPhase
    end

    it 'returns and empty default dstPath' do
      @build_phase.dst_path.should == ''
    end

    it 'defaults the dstSubfolderSpec to the resources folder' do
      @build_phase.dst_subfolder_spec.should == '7'
    end

    describe '#pretty_print' do
      it 'returns the pretty print representation' do
        @build_phase.pretty_print.should == {
          'CopyFiles' => {
            'Destination Path' => '',
            'Destination Subfolder' => 'resources',
            'Files' => [],
          },
        }
      end
    end

    describe '#symbol_dst_subfolder_spec' do
      it 'returns the matching value' do
        @build_phase.symbol_dst_subfolder_spec.should == :resources
      end

      it 'returns nil if the key is unknown' do
        @build_phase.dst_subfolder_spec = '42'
        @build_phase.symbol_dst_subfolder_spec.should.be.nil
      end
    end

    describe '#symbol_dst_subfolder_spec=' do
      it 'accepts valid values' do
        @build_phase.symbol_dst_subfolder_spec = :frameworks
        @build_phase.symbol_dst_subfolder_spec.should == :frameworks
      end

      it 'raises if an invalid value is set by #symbol_dst_subfolder_spec=' do
        lambda { @build_phase.symbol_dst_subfolder_spec = :watch_faces }.should.raise?(StandardError)
      end
    end
  end

  describe PBXShellScriptBuildPhase do
    before do
      @build_phase = @project.new(PBXShellScriptBuildPhase)
    end

    it 'uses the shell in /bin/sh as the default interpreter' do
      @build_phase.shell_path.should == '/bin/sh'
    end

    it 'has empty defaults for the other attributes' do
      @build_phase.files.should == []
      @build_phase.input_paths.should == []
      @build_phase.input_file_list_paths.should == []
      @build_phase.output_paths.should == []
      @build_phase.output_file_list_paths.should == []
      @build_phase.shell_script.should == "# Type a script or drag a script file from your workspace to insert its path.\n"
    end

    it 'returns wether or not env vars should be shown in the log' do
      @build_phase.show_env_vars_in_log.should.be.nil
      @build_phase.show_env_vars_in_log = '0'
      @build_phase.show_env_vars_in_log.should == '0'
    end

    describe '#pretty_print' do
      it 'returns the pretty print representation' do
        @build_phase.pretty_print.should == {
          'ShellScript' => {
            'Input File List Paths' => [],
            'Input Paths' => [],
            'Output File List Paths' => [],
            'Output Paths' => [],
            'Shell Path' => '/bin/sh',
            'Shell Script' => "# Type a script or drag a script file from your workspace to insert its path.\n",
          },
        }
      end
    end
  end
end
