require File.expand_path('../spec_helper', __FILE__)

# rubocop:disable Style/Tab
SPEC_XCODEBUILD_SAMPLE_SDK_OTPUT = <<-DOC
OS X SDKs:
	Mac OS X 10.7                 	-sdk macosx10.7
	OS X 10.8                     	-sdk macosx10.8

iOS SDKs:
	iOS 6.1                       	-sdk iphoneos6.1

iOS Simulator SDKs:
	Simulator - iOS 6.1           	-sdk iphonesimulator6.1

tvOS SDKs:
  tvOS 9.0                        -sdk appletvos9.0

tvOS Simulator SDKs:
  Simulator - tvOS 9.0            -sdk appletvsimulator9.0

watchOS SDKs:
  Watch OS 2.0                    -sdk watchos2.0

watchOS Simulator SDKs:
  Simulator - Watch OS 2.0        -sdk watchsimulator2.0
DOC
# rubocop:enable Style/Tab

module Xcodeproj
  describe XcodebuildHelper do
    before do
      @helper = XcodebuildHelper.new
      @helper.stubs(:xcodebuild_sdks).returns(SPEC_XCODEBUILD_SAMPLE_SDK_OTPUT)
    end

    #--------------------------------------------------------------------------------#

    describe 'In general' do
      before do
        @helper.stubs(:xcodebuild_available?).returns(true)
      end

      it 'returns the last iOS SDK' do
        @helper.last_ios_sdk.should == '6.1'
      end

      it 'returns the last OS X SDK' do
        @helper.last_osx_sdk.should == '10.8'
      end

      it 'returns the last tvOS SDK' do
        @helper.last_tvos_sdk.should == '9.0'
      end

      it 'returns the last watchOS SDK' do
        @helper.last_watchos_sdk.should == '2.0'
      end
    end

    #--------------------------------------------------------------------------------#

    describe 'Private helpers' do
      describe '#xcodebuild_available?' do
        it 'returns whether the xcodebuild command is available' do
          Process::Status.any_instance.expects(:exitstatus).returns(0)
          @helper.send(:xcodebuild_available?).should.be.true
        end

        it 'returns whether the xcodebuild command is available' do
          Process::Status.any_instance.expects(:exitstatus).returns(1)
          @helper.send(:xcodebuild_available?).should.be.false
        end
      end

      describe '#parse_sdks_information' do
        it 'parses the sdks information returned by xcodebuild' do
          result = @helper.send(:parse_sdks_information, SPEC_XCODEBUILD_SAMPLE_SDK_OTPUT)
          result.should == [['macosx', '10.7'], ['macosx', '10.8'], ['iphoneos', '6.1'], ['appletvos', '9.0'], ['watchos', '2.0']]
        end
      end
    end

    #--------------------------------------------------------------------------------#
  end
end
