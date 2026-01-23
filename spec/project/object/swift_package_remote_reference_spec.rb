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

    it 'returns the ascii plist annotation without the .git extension of repositoryURL' do
      @proxy.repositoryURL = 'github.com/swift/package.git'
      @proxy.ascii_plist_annotation.should == ' XCRemoteSwiftPackageReference "package" '
    end

    it 'returns the ascii plist annotation with the part before the first dot for URLs with dotted names' do
      @proxy.repositoryURL = 'https://github.com/socketio/socket.io-client-swift'
      @proxy.ascii_plist_annotation.should == ' XCRemoteSwiftPackageReference "socket" '
    end

    it 'returns the ascii plist annotation with the part before the first dot for git@ URLs with dotted names' do
      @proxy.repositoryURL = 'git@github.com:socketio/socket.io-client-swift.git'
      @proxy.ascii_plist_annotation.should == ' XCRemoteSwiftPackageReference "socket" '
    end
  end
end
