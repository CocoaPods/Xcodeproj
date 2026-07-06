require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXFileSystemSynchronizedBuildFileExceptionSet do
    before do
      @exception_set = @project.new(PBXFileSystemSynchronizedBuildFileExceptionSet)
    end

    it 'supports serializing asset tags by relative path' do
      @exception_set.asset_tags_by_relative_path = {
        'Demo Content.localized' => ['featured-videos'],
      }

      @exception_set.to_hash['assetTagsByRelativePath'].should == {
        'Demo Content.localized' => ['featured-videos'],
      }
    end

    it 'supports deserializing asset tags by relative path from plist data' do
      uuid = 'F00BA4F00BA4F00BA4F00BA4'
      exception_set = PBXFileSystemSynchronizedBuildFileExceptionSet.new(@project, uuid)
      objects_by_uuid_plist = {
        uuid => {
          'isa' => 'PBXFileSystemSynchronizedBuildFileExceptionSet',
          'assetTagsByRelativePath' => {
            'Demo Content.localized' => ['featured-videos'],
          },
        },
      }

      UI.expects(:warn).never
      exception_set.configure_with_plist(objects_by_uuid_plist)

      exception_set.asset_tags_by_relative_path.should == {
        'Demo Content.localized' => ['featured-videos'],
      }
    end
  end
end
