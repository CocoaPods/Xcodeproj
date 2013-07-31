module Xcodeproj
  class Project
    module ProjectHelper

      include Object

      # @!group Targets

      #-----------------------------------------------------------------------#

      # Creates a new target and adds it to the project.
      #
      # The target is configured for the given platform and its file reference it
      # is added to the {products_group}.
      #
      # The target is pre-populated with common build settings, and the
      # appropriate Framework according to the platform is added to to its
      # Frameworks phase.
      #
      # @param  [Project] project
      #         the project to which the target should be added.
      #
      # @param  [Symbol] type
      #         the type of target. Can be `:application`, `:dynamic_library` or
      #         `:static_library`.
      #
      # @param  [String] name
      #         the name of the static library product.
      #
      # @param  [Symbol] platform
      #         the platform of the static library. Can be `:ios` or `:osx`.
      #
      # @param  [String] deployment_target
      #         the deployment target for the platform.
      #
      # @return [PBXNativeTarget] the target.
      #
      def self.new_target(project, type, name, platform, deployment_target)

        # Target
        target = project.new(PBXNativeTarget)
        project.targets << target
        target.name = name
        target.product_name = name
        target.product_type = Constants::PRODUCT_TYPE_UTI[type]
        target.build_configuration_list = configuration_list(project, platform, deployment_target)

        # Product
        product = project.products_group.new_static_library(name)
        target.product_reference = product

        # Frameworks
        framework_name = (platform == :ios) ? 'Foundation' : 'Cocoa'
        framework_ref = project.add_system_framework(framework_name, target)

        # Build phases
        target.build_phases << project.new(PBXSourcesBuildPhase)
        frameworks_phase = project.new(PBXFrameworksBuildPhase)
        frameworks_phase.add_file_reference(framework_ref)
        target.build_phases << frameworks_phase

        target
      end

      # Creates a new resource bundles target and adds it to the project.
      #
      # The target is configured for the given platform and its file reference it
      # is added to the {products_group}.
      #
      # The target is pre-populated with common build settings
      #
      # @param  [Project] project
      #         the project to which the target should be added.
      #
      # @param  [String] name
      #         the name of the resources bundle.
      #
      # @param  [Symbol] platform
      #         the platform of the resources bundle. Can be `:ios` or `:osx`.
      #
      # @return [PBXNativeTarget] the target.
      #
      def self.new_resources_bundle(project, name, platform)
        # Target
        target = project.new(PBXNativeTarget)
        project.targets << target
        target.name = name
        target.product_name = name
        target.product_type = Constants::PRODUCT_TYPE_UTI[:bundle]

        # Configuration List
        build_settings = {
          'PRODUCT_NAME' => '"$(TARGET_NAME)"',
          'WRAPPER_EXTENSION' => 'bundle',
          'SKIP_INSTALL' => 'YES'
        }
        if platform == :osx
          build_settings['COMBINE_HIDPI_IMAGES'] = 'YES'
        end
        cl = project.new(XCConfigurationList)
        cl.default_configuration_is_visible = '0'
        cl.default_configuration_name = 'Release'
        release_conf = project.new(XCBuildConfiguration)
        release_conf.name = 'Release'
        release_conf.build_settings = build_settings
        debug_conf = project.new(XCBuildConfiguration)
        debug_conf.name = 'Debug'
        debug_conf.build_settings = build_settings
        cl.build_configurations << release_conf
        cl.build_configurations << debug_conf
        cl
        target.build_configuration_list = cl

        # Product
        product = project.products_group.new_bundle(name)
        target.product_reference = product

        # # Frameworks
        # framework_name = (platform == :ios) ? 'Foundation' : 'Cocoa'
        # framework_ref = add_system_framework(framework_name, target)

        # Build phases
        target.build_phases << project.new(PBXSourcesBuildPhase)
        target.build_phases << project.new(PBXFrameworksBuildPhase)
        target.build_phases << project.new(PBXResourcesBuildPhase)
        # frameworks_phase = project.new(PBXFrameworksBuildPhase)
        # frameworks_phase.add_file_reference(framework_ref)
        # target.build_phases << frameworks_phase

        target
      end

      # @!group System Frameworks

      #-----------------------------------------------------------------------#

      # Adds a file reference for a system framework to the project.
      #
      # The file reference can then be added to the build files of a
      # {PBXFrameworksBuildPhase}.
      #
      # @param  [Project] project
      #         the project to which the configuration list should be added.
      #
      # @param  [String] name
      #         The name of a framework.
      #
      # @param  [PBXNativeTarget] target
      #         The target for which to add the framework.
      #
      # @note   This method adds a reference to the highest know SDK for the
      #         given platform.
      #
      # @return [PBXFileReference] The generated file reference.
      #
      def self.add_system_framework(project, name, target)
        sdk = target.sdk
        raise "Unable to find and SDK for the target `#{target.name}`" unless sdk
        if sdk.include?('iphoneos')
          if sdk == 'iphoneos'
            version = XcodebuildHelper.instance.last_ios_sdk || Constants::LAST_KNOWN_IOS_SDK
            base_dir = "Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS#{version}.sdk/"
          else
            base_dir = "Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS#{sdk.gsub('iphoneos', '')}.sdk/"
          end
        elsif sdk.include?('macosx')
          if sdk == 'macosx'
            version = XcodebuildHelper.instance.last_osx_sdk || Constants::LAST_KNOWN_OSX_SDK
            base_dir = "Platforms/MacOSX.platform/Developer/SDKs/MacOSX#{version}.sdk/"
          else
            base_dir = "Platforms/MacOSX.platform/Developer/SDKs/MacOSX#{sdk.gsub('macosx', '')}.sdk/"
          end
        end

        path = base_dir + "System/Library/Frameworks/#{name}.framework"
        if ref = project.frameworks_group.files.find { |f| f.path == path }
          ref
        else
          ref = project.frameworks_group.new_file(path)
          ref.source_tree = 'DEVELOPER_DIR'
          ref
        end
      end

      # @!group Private Helpers

      #-----------------------------------------------------------------------#

      # Returns a new configuration list, populated with release and debug
      # configurations with common build settings for the given platform.
      #
      # @param  [Project] project
      #         the project to which the configuration list should be added.
      #
      # @param  [Symbol] platform
      #         the platform for the configuration list, can be `:ios` or `:osx`.
      #
      # @param  [String] deployment_target
      #         the deployment target for the platform.
      #
      # @return [XCConfigurationList] the generated configuration list.
      #
      def self.configuration_list(project, platform, deployment_target = nil)
        cl = project.new(XCConfigurationList)
        cl.default_configuration_is_visible = '0'
        cl.default_configuration_name = 'Release'

        release_conf = project.new(XCBuildConfiguration)
        release_conf.name = 'Release'
        release_conf.build_settings = common_build_settings(:release, platform, deployment_target)

        debug_conf = project.new(XCBuildConfiguration)
        debug_conf.name = 'Debug'
        debug_conf.build_settings = common_build_settings(:debug, platform, deployment_target)

        cl.build_configurations << release_conf
        cl.build_configurations << debug_conf
        cl
      end

      # Returns the common build settings for a given platform and configuration
      # name.
      #
      # @param  [Symbol] type
      #         the type of the build configuration, can be `:release` or
      #         `:debug`.
      #
      # @param  [Symbol] platform
      #         the platform for the build settings, can be `:ios` or `:osx`.
      #
      # @param  [String] deployment_target
      #         the deployment target for the platform.
      #
      # @return [Hash] The common build settings
      #
      def self.common_build_settings(type, platform, deployment_target = nil)
        common_settings = Constants::COMMON_BUILD_SETTINGS
        settings = common_settings[:all].dup
        settings.merge!(common_settings[type])
        settings.merge!(common_settings[platform])
        settings.merge!(common_settings[[platform, type]])
        if deployment_target
          if platform == :ios
            settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
          elsif platform == :osx
            settings['MACOSX_DEPLOYMENT_TARGET'] = deployment_target
          end
        end
        settings
      end

      #-----------------------------------------------------------------------#

    end
  end
end
