require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::XCLocalSwiftPackageReference do
    before do
      @proxy = @project.new(XCLocalSwiftPackageReference)
    end

    it 'returns default display_name if path is not set' do
      @proxy.display_name.should == 'LocalSwiftPackageReference'
    end

    it 'returns path for display_name if path is set' do
      @proxy.path = '../path'
      @proxy.display_name.should == '../path'
    end

    it 'returns the ascii plist annotation with the last component of path' do
      @proxy.path = '../path'
      @proxy.ascii_plist_annotation.should == ' XCLocalSwiftPackageReference "path" '
    end
  end
end
