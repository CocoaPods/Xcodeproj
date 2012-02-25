require File.expand_path('../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project" do
    it "returns the objects hash" do
      @project.objects_hash.should == @project.to_hash['objects']
    end

    it "returns the objects as PBXObject instances" do
      @project.objects.each do |object|
        @project.objects_hash[object.uuid].should == object.attributes
      end
    end

    it "adds any type of new PBXObject to the objects hash" do
      object = @project.objects.add(PBXObject, 'name' => 'An Object')
      object.name.should == 'An Object'
      @project.objects_hash[object.uuid].should == object.attributes
    end

    it "adds a new PBXObject, of the configured type, to the objects hash" do
      group = @project.groups.new('name' => 'A new group')
      group.isa.should == 'PBXGroup'
      group.name.should == 'A new group'
      @project.objects_hash[group.uuid].should == group.attributes
    end

    it "adds a new PBXFileReference to the objects hash" do
      file = @project.files.new('path' => '/some/file.m')
      file.isa.should == 'PBXFileReference'
      file.name.should == 'file.m'
      file.path.should == '/some/file.m'
      file.sourceTree.should == 'SOURCE_ROOT'
      @project.objects_hash[file.uuid].should == file.attributes
    end

    it "adds a new PBXBuildFile to the objects hash when a new PBXFileReference is created" do
      file = @project.files.new('name' => '/some/source/file.h')
      build_file = file.buildFiles.new
      build_file.file = file
      build_file.fileRef.should == file.uuid
      build_file.isa.should == 'PBXBuildFile'
      @project.objects_hash[build_file.uuid].should == build_file.attributes
    end

    it "adds an `m' or `c' file to the `sources build' phase list" do
      %w{ m mm c cpp }.each do |ext|
        path = Pathname.new("path/to/file.#{ext}")
        file = @target.add_source_file(path)
        # ensure that it was added to all objects
        file = @project.objects[file.uuid]

        phase = @target.buildPhases.find { |phase| phase.is_a?(PBXSourcesBuildPhase) }
        phase.files.map { |buildFile| buildFile.file }.should.include file

        phase = @target.buildPhases.find { |phase| phase.is_a?(PBXCopyFilesBuildPhase) }
        phase.files.map { |buildFile| buildFile.file }.should.not.include file
      end
    end

    it "adds custom compiler flags to the PBXBuildFile object if specified" do
      build_file_uuids = []
      %w{ m mm c cpp }.each do |ext|
        path = Pathname.new("path/to/file.#{ext}")
        file = @project.targets.first.add_source_file(path, nil, '-fno-obj-arc')
        find_object({
          'isa' => 'PBXBuildFile',
          'fileRef' => file.uuid,
          'settings' => {'COMPILER_FLAGS' => '-fno-obj-arc' }
        }).should.not == nil
      end
    end

    # TODO add test for the optional copy_header_phase
    #it "adds a `h' file as a build file and adds it to the `headers build' phase list" do
    it "adds a `h' file as a build file and adds it to the `copy header files' build phase list" do
      path = Pathname.new("path/to/file.h")
      file = @target.add_source_file(path)
      # ensure that it was added to all objects
      file = @project.objects[file.uuid]

      phase = @target.buildPhases.find { |phase| phase.is_a?(PBXSourcesBuildPhase) }
      phase.files.map { |buildFile| buildFile.file }.should.not.include file

      phase = @target.buildPhases.find { |phase| phase.is_a?(PBXCopyFilesBuildPhase) }
      phase.files.map { |buildFile| buildFile.file }.should.include file
    end

    extend SpecHelper::TemporaryDirectory

    it "saves the template with the adjusted project" do
      @project.save_as(File.join(temporary_directory, 'Pods.xcodeproj'))
      project_file = (temporary_directory + 'Pods.xcodeproj/project.pbxproj')
      Xcodeproj.read_plist(project_file.to_s).should == @project.to_hash
    end

    it "returns all source files" do
      group = @project.groups.new('name' => 'SomeGroup')
      files = [Pathname.new('/some/file.h'), Pathname.new('/some/file.m')]
      files.each { |file| group << @target.add_source_file(file) }
      group.source_files.map(&:pathname).sort.should == files.sort
    end
  end
end
