module Xcodeproj
  class Project
    module Object

      class XCBuildConfiguration < AbstractPBXObject
        COMMON_BUILD_SETTINGS = {
          :all => {
            'GCC_VERSION'                       => 'com.apple.compilers.llvm.clang.1_0',
            'GCC_PRECOMPILE_PREFIX_HEADER'      => 'YES',
            'PRODUCT_NAME'                      => '$(TARGET_NAME)',
            'SKIP_INSTALL'                      => 'YES',
            'DSTROOT'                           => '/tmp/xcodeproj.dst',
            'ALWAYS_SEARCH_USER_PATHS'          => 'NO',
            'GCC_C_LANGUAGE_STANDARD'           => 'gnu99',
            'INSTALL_PATH'                      => "$(BUILT_PRODUCTS_DIR)",
            'OTHER_LDFLAGS'                     => '',
            'COPY_PHASE_STRIP'                  => 'YES',
          }.freeze,
          :debug => {
            'GCC_DYNAMIC_NO_PIC'                => 'NO',
            'GCC_PREPROCESSOR_DEFINITIONS'      => ["DEBUG=1", "$(inherited)"],
            'GCC_SYMBOLS_PRIVATE_EXTERN'        => 'NO',
            'GCC_OPTIMIZATION_LEVEL'            => '0',
            'COPY_PHASE_STRIP'                  => 'NO',
          }.freeze,
          :ios => {
            'ARCHS'                             => "$(ARCHS_STANDARD_32_BIT)",
            'IPHONEOS_DEPLOYMENT_TARGET'        => '4.3',
            'PUBLIC_HEADERS_FOLDER_PATH'        => "$(TARGET_NAME)",
            'SDKROOT'                           => 'iphoneos',
          }.freeze,
          :osx => {
            'ARCHS'                             => "$(ARCHS_STANDARD_64_BIT)",
            'GCC_ENABLE_OBJC_EXCEPTIONS'        => 'YES',
            'GCC_VERSION'                       => 'com.apple.compilers.llvm.clang.1_0',
            'MACOSX_DEPLOYMENT_TARGET'          => '10.7',
            'SDKROOT'                           => 'macosx',
            'COMBINE_HIDPI_IMAGES'              => 'YES',
          }.freeze,
          [:osx, :debug] => {
            'ONLY_ACTIVE_ARCH'                  => 'YES',
          }.freeze,
          [:osx, :release] => {
            'DEBUG_INFORMATION_FORMAT'          => 'dwarf-with-dsym',
          }.freeze,
          [:ios, :release] => {
            'VALIDATE_PRODUCT'                  => 'YES',
          }.freeze,
        }.freeze

        def self.new_release(project)
          new(project, nil,
            'name' => 'Release',
            'buildSettings' => COMMON_BUILD_SETTINGS[:all].dup
          )
        end

        def self.new_debug(project)
          new(project, nil,
            'name' => 'Debug',
            'buildSettings' => COMMON_BUILD_SETTINGS[:all].merge(COMMON_BUILD_SETTINGS[:debug])
          )
        end

        # [Hash] the build settings used when building a target
        attribute :build_settings

        # TODO why do I need to specify the uuid here?
        has_one :base_configuration, :uuid => :base_configuration_reference

        def initialize(*)
          super
          self.build_settings ||= {}
        end

        def destroy
          base_configuration.destroy if base_configuration
          super
        end
      end

      class XCConfigurationList < AbstractPBXObject
        attribute :default_configuration_is_visible
        attribute :default_configuration_name

        has_many :build_configurations

        def initialize(*)
          super
          self.build_configuration_references ||= []
        end

        def destroy
          build_configurations.each(&:destroy)
          super
        end

        def build_settings(build_configuration_name)
          if config = build_configurations.where(:name => build_configuration_name)
            config.build_settings
          end
        end
      end

    end
  end
end
