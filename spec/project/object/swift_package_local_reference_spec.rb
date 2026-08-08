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
      @proxy.relative_path = '../path'
      @proxy.display_name.should == '../path'
    end

    it 'returns the ascii plist annotation with the last component of path' do
      @proxy.relative_path = '../path'
      @proxy.ascii_plist_annotation.should == ' XCLocalSwiftPackageReference "path" '
    end

    it 'supports serializing traits' do
      @proxy.traits = %w(Textual Logging)

      @proxy.to_hash['traits'].should == %w(Textual Logging)
    end

    it 'supports deserializing traits from plist data' do
      uuid = 'F00BA4F00BA4F00BA4F00BA4'
      package_reference = XCLocalSwiftPackageReference.new(@project, uuid)
      objects_by_uuid_plist = {
        uuid => {
          'isa' => 'XCLocalSwiftPackageReference',
          'traits' => %w(Textual Logging),
        },
      }

      UI.expects(:warn).never
      package_reference.configure_with_plist(objects_by_uuid_plist)

      package_reference.traits.should == %w(Textual Logging)
    end
  end
end
