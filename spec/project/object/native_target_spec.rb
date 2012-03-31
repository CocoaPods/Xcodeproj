require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXNativeTarget" do
    it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
      @target.name.should == "Pods"
      @target.product_name.should == "Pods"
    end

    it "returns the product" do
      product = @target.product
      product.uuid.should == @target.product_reference
      product.should.be.instance_of PBXFileReference
      product.path.should == "libPods.a"
      product.name.should == "libPods.a"
      product.group.name.should == "Products"
      product.source_tree.should == "BUILT_PRODUCTS_DIR"
      product.explicit_file_type.should == "archive.ar"
      product.include_in_index.should == "0"
    end

    it "adds the product to the Products group in the main group" do
      @project.products.should.include @target.product
    end

    it "returns that product type is a static library" do
      @target.product_type.should == "com.apple.product-type.library.static"
    end

    it "returns the buildConfigurationList" do
      list = @target.build_configuration_list
      list.should.be.instance_of XCConfigurationList
      list.build_configurations.each do |configuration|
        configuration.build_settings.should == {
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
      @target.build_rules.to_a.should == []
    end
  end

  describe "Xcodeproj::Project::Object::PBXNativeTarget, concerning its build phases" do
    {
      :source_build_phases       => PBXSourcesBuildPhase,
      :copy_files_build_phases   => PBXCopyFilesBuildPhase,
      :frameworks_build_phases   => PBXFrameworksBuildPhase,
      :shell_script_build_phases => PBXShellScriptBuildPhase
    }.each do |association_method, klass|
      unless klass == PBXShellScriptBuildPhase
        it "returns an empty #{klass.isa}" do
          phases = @target.send(association_method)
          phases.size.should == 1
          phases.first.should.be.instance_of klass
          phases.first.files.to_a.should == []
        end
      end

      it "adds a #{klass.isa}" do
        phases = @target.send(association_method)
        before = phases.size
        phase = @target.send(association_method).new
        phase.should.be.instance_of klass
        phases.size.should == before + 1
        phases.should.include phase
      end
    end

    it "adds frameworks the frameworks in a group named 'Frameworks' in the main group to a new target" do
      file = @project.add_system_framework('QuartzCore')
      group = @project.groups.where(:name => 'Frameworks')
      target = @project.targets.new
      target.frameworks_build_phases.first.files.should == [file]
    end
  end
end
