require File.expand_path('../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project" do
    it "returns the objects hash" do
      @project.objects_hash.should == @project.to_hash['objects']
    end

    it "compares the objects hash" do
      @project.should == @project.to_hash
    end

    it "adds an object hash to the objects hash" do
      attributes = { 'isa' => 'PBXFileReference', 'path' => 'some/file.m' }
      @project.add_object_hash('UUID', attributes)
      @project.objects_hash['UUID'].should == attributes
    end

    it "raises an argument error if the value of the `isa' attribute is AbstractPBXObject, because it doesn't actually belong in an xcodeproject" do
      lambda {
        @project.add_object_hash('UUID', 'isa' => 'AbstractPBXObject')
      }.should.raise ArgumentError
    end

    it "returns the objects as AbstractPBXObject instances" do
      @project.objects.each do |object|
        @project.objects_hash[object.uuid].should == object.attributes
      end
    end

    it "adds any type of new AbstractPBXObject to the objects hash" do
      object = new_instance(AbstractPBXObject, 'name' => 'An Object')
      object.name.should == 'An Object'
      @project.objects_hash[object.uuid].should == object.attributes
    end

    it "adds a new AbstractPBXObject, of the configured type, to the objects hash" do
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
      file.source_tree.should == 'SOURCE_ROOT'
      @project.objects_hash[file.uuid].should == file.attributes
    end

    it "adds a new PBXBuildFile to the objects hash when a new PBXFileReference is created" do
      file = @project.files.new('name' => '/some/source/file.h')
      build_file = file.build_files.new
      build_file.file = file
      build_file.file_ref.should == file.uuid
      build_file.isa.should == 'PBXBuildFile'
      @project.objects_hash[build_file.uuid].should == build_file.attributes
    end

    it "returns the products group" do
      @project.products_group.should.be.instance_of PBXGroup
      @project.main_group.children.should.include @project.products_group
      @project.root_object.attributes['productRefGroup'].should == @project.products_group.uuid
      @project.objects_hash[@project.products_group.uuid].should == @project.products_group.attributes
    end

    it "returns the product file references" do
      file = @project.files.new('path' => 'BuildProduct')
      @project.products_group << file
      @project.products.last.should == file
    end

    it "returns the top-level project configurations and build settings" do
      list = @project.root_object.build_configuration_list
      list.default_configuration_name.should == 'Release'
      list.default_configuration_is_visible.should == '0'

      @project.build_settings('Debug').should == {}
      @project.build_settings('Release').should == {}
    end

    it "adds an `m' or `c' file to the `sources build' phase list" do
      %w{ m mm c cpp }.each do |ext|
        path = Pathname.new("path/to/file.#{ext}")
        file = @target.add_source_files([{:path => path}]).first
        # ensure that it was added to all objects
        file = @project.objects[file.uuid]

        phase = @target.build_phases.find { |phase| phase.is_a?(PBXSourcesBuildPhase) }
        phase.files.should.include file

        phase = @target.build_phases.find { |phase| phase.is_a?(PBXCopyFilesBuildPhase) }
        phase.files.should.not.include file
      end
    end

    it "adds custom compiler flags to the PBXBuildFile object if specified" do
      build_file_uuids = []
      %w{ m mm c cpp }.each do |ext|
        path = Pathname.new("path/to/file.#{ext}")
        file = @project.targets.first.add_source_files([{:path => path, :compiler_flags => '-fno-obj-arc'}]).first
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
      file = @target.add_source_files([{:path => path}]).first
      # ensure that it was added to all objects
      file = @project.objects[file.uuid]

      phase = @target.build_phases.find { |phase| phase.is_a?(PBXSourcesBuildPhase) }
      phase.files.should.not.include file

      phase = @target.build_phases.find { |phase| phase.is_a?(PBXCopyFilesBuildPhase) }
      phase.files.should.include file
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
      files.each { |file| group << @target.add_source_files([{:path => file}]).first }
      group.source_files.map(&:pathname).sort.should == files.sort
    end
  end
end
