module Xcodeproj
  class Project
    module Object

      class XCBuildConfiguration < PBXObject
        attribute :buildSettings
        has_one :baseConfiguration, :uuid => :baseConfigurationReference

        def initialize(*)
          super
          # TODO These are from an iOS static library, need to check if it works for any product type
          self.buildSettings = {
            'DSTROOT'                      => '/tmp/xcodeproj.dst',
            'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES',
            'GCC_VERSION'                  => 'com.apple.compilers.llvm.clang.1_0',
            'PRODUCT_NAME'                 => '$(TARGET_NAME)',
            'SKIP_INSTALL'                 => 'YES',
          }.merge(buildSettings || {})
        end
      end

      class XCConfigurationList < PBXObject
        has_many :buildConfigurations

        def initialize(*)
          super
          self.buildConfigurationReferences ||= []
        end
      end

    end
  end
end
