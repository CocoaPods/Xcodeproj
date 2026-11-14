require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::XCSwiftPackageProductDependency do
    before do
      @proxy = @project.new(XCSwiftPackageProductDependency)
    end

    it 'returns default display_name if product_name is not set' do
      @proxy.display_name.should == 'SwiftPackageProductDependency'
    end

    it 'returns product_name for display_name if product_name is set' do
      @proxy.product_name = 'NiceSwiftPackage'
      @proxy.display_name.should == 'NiceSwiftPackage'
    end

    it 'strips plugin prefix in ascii plist annotation for plugin products' do
      @proxy.product_name = 'plugin:SwiftLintBuildToolPlugin'
      @proxy.ascii_plist_annotation.should == ' SwiftLintBuildToolPlugin '
    end

    it 'keeps ascii plist annotation unchanged for non-plugin products' do
      @proxy.product_name = 'NiceSwiftPackage'
      @proxy.ascii_plist_annotation.should == ' NiceSwiftPackage '
    end
  end
end
