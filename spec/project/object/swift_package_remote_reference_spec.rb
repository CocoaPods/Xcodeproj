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

    it 'supports serializing traits' do
      @proxy.traits = %w(Textual Logging)

      @proxy.to_hash['traits'].should == %w(Textual Logging)
    end

    it 'supports deserializing traits from plist data' do
      uuid = 'F00BA4F00BA4F00BA4F00BA4'
      package_reference = XCRemoteSwiftPackageReference.new(@project, uuid)
      objects_by_uuid_plist = {
        uuid => {
          'isa' => 'XCRemoteSwiftPackageReference',
          'traits' => %w(Textual Logging),
        },
      }

      UI.expects(:warn).never
      package_reference.configure_with_plist(objects_by_uuid_plist)

      package_reference.traits.should == %w(Textual Logging)
    end
  end
end
