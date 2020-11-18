require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::XCRemoteSwiftPackageReference do
    before do
      @proxy = @project.new(XCRemoteSwiftPackageReference)
    end

    it 'returns default display_name if repositoryURL is not set' do
      @proxy.display_name.should == 'RemoteSwiftPackageReference'
    end

    it 'returns repositoryURL for display_name if repositoryURL is set' do
      @proxy.repositoryURL = 'github.com/swift/package'
      @proxy.display_name.should == 'github.com/swift/package'
    end

    it 'returns the ascii plist annotation with the last component of repositoryURL' do
      @proxy.repositoryURL = 'github.com/swift/package'
      @proxy.ascii_plist_annotation.should == ' XCRemoteSwiftPackageReference "package" '
    end
  end
end
