require File.expand_path('../spec_helper', __FILE__)

describe "Xcode::Project" do
  extend SpecHelper::TemporaryDirectory

  before do
    @project = Xcode::Project.new
  end

  def find_objects(conditions)
    @project.objects_hash.select do |_, object|
      object.objectsForKeys(conditions.keys, notFoundMarker:Object.new) == conditions.values
    end
  end

  def find_object(conditions)
    find_objects(conditions).first
  end

  before do
    @target = @project.targets.new_static_library('Pods')
  end

  it "returns the objects hash" do
    @project.objects_hash.should == @project.to_hash['objects']
  end

  describe "PBXObject" do
    before do
      @object = Xcode::Project::PBXObject.new(@project, nil, 'name' => 'AnObject')
    end

    it "merges the class name into the attributes" do
      @object.isa.should == 'PBXObject'
      @object.attributes['isa'].should == 'PBXObject'
    end

    it "takes a name" do
      @object.name.should == 'AnObject'
      @object.name = 'AnotherObject'
      @object.name.should == 'AnotherObject'
    end

    it "generates a uuid" do
      @object.uuid.should.be.instance_of String
      @object.uuid.size.should == 24
      @object.uuid.should == @object.uuid
    end

    it "adds the object to the objects hash" do
      @project.objects_hash[@object.uuid].should == @object.attributes
    end
  end

  describe "a PBXFileReference" do
    it "sets a default file type" do
      framework, library, xcconfig = %w[framework a xcconfig].map { |n| @project.files.new('path' => "Rockin.#{n}") }
      framework.lastKnownFileType.should == 'wrapper.framework'
      framework.explicitFileType.should == nil
      library.lastKnownFileType.should == nil
      library.explicitFileType.should == 'archive.ar'
      xcconfig.lastKnownFileType.should == 'text.xcconfig'
      xcconfig.explicitFileType.should == nil
    end
    
    it "doesn't set a file type when overridden" do
      fakework = @project.files.new('path' => 'Sup.framework', 'lastKnownFileType' => 'fish')
      fakework.lastKnownFileType.should == 'fish'
      makework = @project.files.new('path' => 'n2m.framework', 'explicitFileType' => 'tree')
      makework.lastKnownFileType.should == nil
    end
    
    before do
      @file = @project.files.new('path' => 'some/file.m')
    end

    it "is automatically added to the main group" do
      @file.group.should == @project.main_group
    end

    it "is removed from the original group when added to another group" do
      group = @project.groups.new
      group.children << @file
      @file.group.should == group
      @project.main_group.children.should.not.include @file
    end
  end

  describe "a new PBXBuildPhase" do
    before do
      @phase = @project.objects.add(Xcode::Project::PBXBuildPhase)
    end

    it "has an empty list of files" do
      @phase.files.to_a.should == []
    end

    it "always returns the same buildActionMask (no idea what it is)" do
      @phase.buildActionMask.should == "2147483647"
    end

    it "always returns zero for runOnlyForDeploymentPostprocessing (no idea what it is)" do
      @phase.runOnlyForDeploymentPostprocessing.should == "0"
    end
  end

  describe "a new PBXCopyFilesBuildPhase" do
    before do
      @phase = @project.objects.add(Xcode::Project::PBXCopyFilesBuildPhase, 'dstPath' => 'some/path')
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of Xcode::Project::PBXBuildPhase
    end

    it "returns the dstPath" do
      @phase.dstPath.should == 'some/path'
    end

    it "returns the dstSubfolderSpec (no idea what it is yet, but it's not always the same)" do
      @phase.dstSubfolderSpec.should == "16"
    end
  end

  describe "a new PBXSourcesBuildPhase" do
    before do
      @phase = @project.objects.add(Xcode::Project::PBXSourcesBuildPhase)
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of Xcode::Project::PBXBuildPhase
    end
  end

  describe "a new PBXFrameworksBuildPhase" do
    before do
      @phase = @project.objects.add(Xcode::Project::PBXFrameworksBuildPhase)
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of Xcode::Project::PBXBuildPhase
    end
  end

  describe "a new XCBuildConfiguration" do
    before do
      @configuration = @project.objects.add(Xcode::Project::XCBuildConfiguration)
    end

    it "returns the xcconfig that this configuration is based on (baseConfigurationReference)" do
      xcconfig = @project.objects.new
      @configuration.baseConfiguration = xcconfig
      @configuration.baseConfigurationReference.should == xcconfig.uuid
    end
  end

  describe "a new XCConfigurationList" do
    before do
      @list = @project.objects.add(Xcode::Project::XCConfigurationList)
    end

    it "returns the configurations" do
      configuration = @project.objects.add(Xcode::Project::XCBuildConfiguration)
      @list.buildConfigurations.to_a.should == []
      @list.buildConfigurations = [configuration]
      @list.buildConfigurationReferences.should == [configuration.uuid]
    end
  end

  describe "a new PBXNativeTarget" do
    it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
      @target.name.should == "Pods"
      @target.productName.should == "Pods"
    end

    it "returns the product" do
      product = @target.product
      product.uuid.should == @target.productReference
      product.should.be.instance_of Xcode::Project::PBXFileReference
      product.path.should == "libPods.a"
      product.name.should == "libPods.a"
      product.group.name.should == "Products"
      product.sourceTree.should == "BUILT_PRODUCTS_DIR"
      product.explicitFileType.should == "archive.ar"
      product.includeInIndex.should == "0"
    end

    it "returns that product type is a static library" do
      @target.productType.should == "com.apple.product-type.library.static"
    end

    it "returns the buildConfigurationList" do
      list = @target.buildConfigurationList
      list.should.be.instance_of Xcode::Project::XCConfigurationList
      list.buildConfigurations.each do |configuration|
        configuration.buildSettings.should == {
          'DSTROOT'                      => '/tmp/xcodeproj.dst',
          'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES',
          'GCC_VERSION'                  => 'com.apple.compilers.llvm.clang.1_0',
          'PRODUCT_NAME'                 => '$(TARGET_NAME)',
          'SKIP_INSTALL'                 => 'YES',
        }
      end
    end

    it "returns an empty list of dependencies and buildRules (not sure yet which classes those are yet)" do
      @target.dependencies.to_a.should == []
      @target.buildRules.to_a.should == []
    end

    describe "concerning its build phases" do
      extend SpecHelper::TemporaryDirectory

      it "returns an empty sources build phase" do
        phase = @target.buildPhases.select_by_class(Xcode::Project::PBXSourcesBuildPhase).first
        phase.files.to_a.should == []
      end

      it "returns a libraries/frameworks build phase, which by default is empty" do
        phase = @target.buildPhases.select_by_class(Xcode::Project::PBXFrameworksBuildPhase).first
        phase.should.not == nil
      end

      it "returns an empty 'copy headers' phase" do
        phase = @target.buildPhases.select_by_class(Xcode::Project::PBXCopyFilesBuildPhase).first
        phase.dstPath.should == "$(PUBLIC_HEADERS_FOLDER_PATH)"
        phase.files.to_a.should == []
      end
    end
  end

  it "returns the objects as PBXObject instances" do
    @project.objects.each do |object|
      @project.objects_hash[object.uuid].should == object.attributes
    end
  end

  it "adds any type of new PBXObject to the objects hash" do
    object = @project.objects.add(Xcode::Project::PBXObject, 'name' => 'An Object')
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

      phase = @target.buildPhases.find { |phase| phase.is_a?(Xcode::Project::PBXSourcesBuildPhase) }
      phase.files.map { |buildFile| buildFile.file }.should.include file

      phase = @target.buildPhases.find { |phase| phase.is_a?(Xcode::Project::PBXCopyFilesBuildPhase) }
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

    phase = @target.buildPhases.find { |phase| phase.is_a?(Xcode::Project::PBXSourcesBuildPhase) }
    phase.files.map { |buildFile| buildFile.file }.should.not.include file

    phase = @target.buildPhases.find { |phase| phase.is_a?(Xcode::Project::PBXCopyFilesBuildPhase) }
    phase.files.map { |buildFile| buildFile.file }.should.include file
  end

  it "saves the template with the adjusted project" do
    @project.save_as(File.join(temporary_directory, 'Pods.xcodeproj'))
    project_file = (temporary_directory + 'Pods.xcodeproj/project.pbxproj')
    NSDictionary.dictionaryWithContentsOfFile(project_file.to_s).should == @project.to_hash
  end

  it "returns all source files" do
    group = @project.groups.new('name' => 'SomeGroup')
    files = [Pathname.new('/some/file.h'), Pathname.new('/some/file.m')]
    files.each { |file| group << @target.add_source_file(file) }
    group.source_files.map(&:pathname).sort.should == files.sort
  end
end
