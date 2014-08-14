module Xcodeproj
  # Helper class which returns information from xcodebuild.
  #
  class XcodebuildHelper
    def initialize
      @needs_to_parse_sdks = true
    end

    # @return [String] The version of the last iOS sdk.
    #
    def last_ios_sdk
      parse_sdks_if_needed
      verions_by_sdk[:ios].sort.last
    end

    # @return [String] The version of the last OS X sdk.
    #
    def last_osx_sdk
      parse_sdks_if_needed
      verions_by_sdk[:osx].sort.last
    end

    private

    # !@group Private Helpers

    #-------------------------------------------------------------------------#

    # @return [Hash] The versions of the sdks grouped by name (`:ios`, or `:osx`).
    #
    attr_accessor :verions_by_sdk

    # @return [void] Parses the SDKs returned by xcodebuild and stores the
    #         information in the `needs_to_parse_sdks` hash.
    #
    def parse_sdks_if_needed
      if @needs_to_parse_sdks
        @verions_by_sdk = {}
        @verions_by_sdk[:osx] = []
        @verions_by_sdk[:ios] = []
        if xcodebuild_available?
          skds = parse_sdks_information(xcodebuild_sdks)
          skds.each do |(name, version)|
            case
            when name == 'macosx' then @verions_by_sdk[:osx] << version
            when name == 'iphoneos' then @verions_by_sdk[:ios] << version
            end
          end
        end
      end
    end

    # @return [Bool] Whether xcodebuild is available.
    #
    def xcodebuild_available?
      if @xcodebuild_available.nil?
        `which xcodebuild 2>/dev/null`
        @xcodebuild_available = $?.exitstatus.zero?
      end
      @xcodebuild_available
    end

    # @return [Array<Array<String>>] An array of tuples where the first element
    #         is the name of the SDK and the second is the version.
    #
    def parse_sdks_information(output)
      output.scan(/-sdk (macosx|iphoneos)(.+\w)/)
    end

    # @return [String] The sdk information reported by xcodebuild.
    #
    def xcodebuild_sdks
      `xcodebuild -showsdks 2>/dev/null`
    end

    #-------------------------------------------------------------------------#

    # @!group Singleton

    # @return [XcodebuildHelper] the current xcodebuild instance creating one
    #         if needed, which caches the information from the xcodebuild
    #         command line tool.
    #
    def self.instance
      @instance ||= new
    end

    #-------------------------------------------------------------------------#
  end
end
