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
      #         the type of target. Can be `:application`, `:dynamic_library`,
      #         `framework` or `:static_library`.
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
      # @param  [PBXGroup] product_group
      #         the product group, where to add to a file reference of the
      #         created target.
      #
      # @param  [Symbol] language
      #         the primary language of the target, can be `:objc` or `:swift`.
      #
      # @return [PBXNativeTarget] the target.
      #
      def self.new_target(project, type, name, platform, deployment_target, product_group, language)
        # Target
        target = project.new(PBXNativeTarget)
        project.targets << target
        target.name = name
        target.product_name = name
        target.product_type = Constants::PRODUCT_TYPE_UTI[type]
        target.build_configuration_list = configuration_list(project, platform, deployment_target, type, language)

        # Product
        product = product_group.new_product_ref_for_target(name, type)
        target.product_reference = product

        # Build phases
        target.build_phases << project.new(PBXSourcesBuildPhase)
        target.build_phases << project.new(PBXFrameworksBuildPhase)

        # Frameworks
        framework_name = (platform == :osx) ? 'Cocoa' : 'Foundation'
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
      # @param  [PBXGroup] product_group
      #         the product group, where to add to a file reference of the
      #         created target.
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

      # Creates a new aggregate target and adds it to the project.
      #
      # The target is configured for the given platform.
      #
      # @param  [Project] project
      #         the project to which the target should be added.
      #
      # @param  [String] name
      #         the name of the aggregate target.
      #
      # @return [PBXAggregateTarget] the target.
      #
      def self.new_aggregate_target(project, name)
        target = project.new(PBXAggregateTarget)
        project.targets << target
        target.name = name
        target.build_configuration_list = configuration_list(project)
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
      # @param  [Symbol] target_product_type
      #         the product type of the target, can be any of `Constants::PRODUCT_TYPE_UTI.values`
      #         or `Constants::PRODUCT_TYPE_UTI.keys`.
      #
      # @param  [Symbol] language
      #         the primary language of the target, can be `:objc` or `:swift`.
      #
      # @return [XCConfigurationList] the generated configuration list.
      #
      def self.configuration_list(project, platform = nil, deployment_target = nil, target_product_type = nil, language = nil)
        cl = project.new(XCConfigurationList)
        cl.default_configuration_is_visible = '0'
        cl.default_configuration_name = 'Release'

        release_conf = project.new(XCBuildConfiguration)
        release_conf.name = 'Release'
        release_conf.build_settings = common_build_settings(:release, platform, deployment_target, target_product_type, language)

        debug_conf = project.new(XCBuildConfiguration)
        debug_conf.name = 'Debug'
        debug_conf.build_settings = common_build_settings(:debug, platform, deployment_target, target_product_type, language)

        cl.build_configurations << release_conf
        cl.build_configurations << debug_conf

        project.build_configurations.each do |configuration|
          next if cl.build_configurations.map(&:name).include?(configuration.name)

          new_config = project.new(XCBuildConfiguration)
          new_config.name = configuration.name
          new_config.build_settings = common_build_settings(configuration.type, platform, deployment_target, target_product_type, language)
          cl.build_configurations << new_config
        end

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
      # @param  [Symbol] target_product_type
      #         the product type of the target, can be any of
      #         `Constants::PRODUCT_TYPE_UTI.values`
      #         or `Constants::PRODUCT_TYPE_UTI.keys`. Default is :application.
      #
      # @param  [Symbol] language
      #         the primary language of the target, can be `:objc` or `:swift`.
      #
      # @return [Hash] The common build settings
      #
      def self.common_build_settings(type, platform = nil, deployment_target = nil, target_product_type = nil, language = :objc)
        target_product_type = (Constants::PRODUCT_TYPE_UTI.find { |_, v| v == target_product_type } || [target_product_type || :application])[0]
        common_settings = Constants::COMMON_BUILD_SETTINGS

        # Use intersecting settings for all key sets as base
        settings = deep_dup(common_settings[:all])

        # Match further common settings by key sets
        keys = [type, platform, target_product_type, language].compact
        key_combinations = (1..keys.length).flat_map { |n| keys.combination(n).to_a }
        key_combinations.each do |key_combination|
          settings.merge!(deep_dup(common_settings[key_combination] || {}))
        end

        if deployment_target
          case platform
          when :ios then settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
          when :osx then settings['MACOSX_DEPLOYMENT_TARGET'] = deployment_target
          when :tvos then settings['TVOS_DEPLOYMENT_TARGET'] = deployment_target
          when :watchos then settings['WATCHOS_DEPLOYMENT_TARGET'] = deployment_target
          end
        end

        settings
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
