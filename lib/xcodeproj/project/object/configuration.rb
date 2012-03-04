module Xcodeproj
  class Project
    module Object

      class XCBuildConfiguration < PBXObject
        # [Hash] the build settings used when building a target
        attribute :build_settings

        # TODO why do I need to specify the uuid here?
        has_one :base_configuration, :uuid => :base_configuration_reference

        def initialize(*)
          super
          # TODO These are from an iOS static library, need to check if it works for any product type
          self.build_settings = {
            'DSTROOT'                      => '/tmp/xcodeproj.dst',
            'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES',
            'GCC_VERSION'                  => 'com.apple.compilers.llvm.clang.1_0',
            'PRODUCT_NAME'                 => '$(TARGET_NAME)',
            'SKIP_INSTALL'                 => 'YES',
          }.merge(build_settings || {})
        end
      end

      class XCConfigurationList < PBXObject
        has_many :build_configurations

        def initialize(*)
          super
          self.build_configuration_references ||= []
        end
      end

    end
  end
end
