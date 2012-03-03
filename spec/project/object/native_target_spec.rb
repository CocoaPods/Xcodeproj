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
    it "returns an empty sources build phase" do
      phase = @target.build_phases.select_by_class(PBXSourcesBuildPhase).first
      phase.files.to_a.should == []
    end

    it "returns a libraries/frameworks build phase, which by default is empty" do
      phase = @target.build_phases.select_by_class(PBXFrameworksBuildPhase).first
      phase.should.not == nil
    end

    it "returns an empty 'copy headers' phase" do
      phase = @target.build_phases.select_by_class(PBXCopyFilesBuildPhase).first
      phase.dst_path.should == "$(PRODUCT_NAME)"
      phase.files.to_a.should == []
    end
  end
end
