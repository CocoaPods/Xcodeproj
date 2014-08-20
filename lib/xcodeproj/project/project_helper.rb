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
      #         the name of the target product.
      #
      # @param  [Symbol] platform
      #         the platform of the target. Can be `:ios` or `:osx`.
      #
      # @param  [String] deployment_target
      #         the deployment target for the platform.
      #
      # @return [PBXNativeTarget] the target.
      #
      def self.new_target(project, type, name, platform, deployment_target, product_group)
        # Target
        target = project.new(PBXNativeTarget)
        project.targets << target
        target.name = name
        target.product_name = name
        target.product_type = Constants::PRODUCT_TYPE_UTI[type]
        target.build_configuration_list = configuration_list(project, platform, deployment_target)

        # Product
        product = product_group.new_product_ref_for_target(name, type)
        target.product_reference = product

        # Build phases
        target.build_phases << project.new(PBXSourcesBuildPhase)
        target.build_phases << project.new(PBXFrameworksBuildPhase)

        # Frameworks
        framework_name = (platform == :ios) ? 'Foundation' : 'Cocoa'
        target.add_system_framework(framework_name)

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
      def self.new_resources_bundle(project, name, platform, product_group)
        # Target
        target = project.new(PBXNativeTarget)
        project.targets << target
        target.name = name
        target.product_name = name
        target.product_type = Constants::PRODUCT_TYPE_UTI[:bundle]

        build_settings = common_build_settings(nil, platform, nil, target.product_type)

        # Configuration List
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
        target.build_configuration_list = cl

        # Product
        product = product_group.new_bundle(name)
        target.product_reference = product

        # Build phases
        target.build_phases << project.new(PBXSourcesBuildPhase)
        target.build_phases << project.new(PBXFrameworksBuildPhase)
        target.build_phases << project.new(PBXResourcesBuildPhase)

        target
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
      def self.common_build_settings(type, platform, deployment_target = nil, target_product_type = nil)
        if target_product_type == Constants::PRODUCT_TYPE_UTI[:bundle]
          build_settings = {
            'PRODUCT_NAME' => '$(TARGET_NAME)',
            'WRAPPER_EXTENSION' => 'bundle',
            'SKIP_INSTALL' => 'YES',
          }

          if platform == :osx
            build_settings['COMBINE_HIDPI_IMAGES'] = 'YES'
            build_settings['SDKROOT'] = 'macosx'
          else
            build_settings['SDKROOT'] = 'iphoneos'
          end
          build_settings
        else
          common_settings = Constants::COMMON_BUILD_SETTINGS
          settings = deep_dup(common_settings[:all])
          settings.merge!(deep_dup(common_settings[type]))
          settings.merge!(deep_dup(common_settings[platform]))
          settings.merge!(deep_dup(common_settings[[platform, type]]))
          if deployment_target
            if platform == :ios
              settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
            elsif platform == :osx
              settings['MACOSX_DEPLOYMENT_TARGET'] = deployment_target
            end
          end
          settings
        end
      end

      # Creates a deep copy of the given object
      #
      # @param  [Object] object
      #         the object to copy.
      #
      # @return [Object] The deeply copy of the obejct object.
      #
      def self.deep_dup(object)
        case object
        when Hash
          new_hash = {}
          object.each do |key, value|
            new_hash[key] = deep_dup(value)
          end
          new_hash
        when Array
          object.map { |value| deep_dup(value) }
        else
          object.dup
        end
      end

      #-----------------------------------------------------------------------#
    end
  end
end
