module Xcodeproj
  class Project
    module Object
      # The primary purpose of this class is to maintain a collection of
      # related build configurations of a {PBXProject} or a {PBXNativeTarget}.
      #
      class XCConfigurationList < AbstractObject
        # @!group Attributes

        # @return [String] whether the default configuration is visible.
        #         Usually `0`. The purpose of this flag and how Xcode displays
        #         it in the UI is unknown.
        #
        attribute :default_configuration_is_visible, String, '0'

        # @return [String] the name of the default configuration.
        #         Usually `Release`. Xcode exposes this attribute as the
        #         configuration for the command line tools and only allows to
        #         set it at the project level.
        #
        attribute :default_configuration_name, String, 'Release'

        # @return [ObjectList<XCBuildConfiguration>] the build
        #         configurations of the target.
        #
        has_many :build_configurations, XCBuildConfiguration

        public

        # @!group Helpers
        # --------------------------------------------------------------------#

        # Returns the build configuration with the given name.
        #
        # @param  [String] name
        #         The name of the build configuration.
        #
        # @return [XCBuildConfiguration] The build configuration.
        # @return [Nil] If not build configuration with the given name is found.
        #
        def [](name)
          build_configurations.find { |bc| bc.name == name }
        end

        # Returns the build settings of the build configuration with
        # the given name.
        #
        # @param [String] build_configuration_name
        #        The name of the build configuration.
        #
        # @return [Hash {String=>String}] the build settings
        #
        def build_settings(build_configuration_name)
          if config = self[build_configuration_name]
            config.build_settings
          end
        end

        # Gets the value for the given build setting in all the build
        # configurations.
        #
        # @param [String] key
        #        the key of the build setting.
        #
        # @return [Hash{String => String}] The value of the build setting
        #         grouped by the name of the build configuration.
        #
        def get_setting(key)
          result = {}
          build_configurations.each do |bc|
            result[bc.name] = bc.build_settings[key]
          end
          result
        end

        # Sets the given value for the build setting associated with the given
        # key across all the build configurations.
        #
        # @param [String] key
        #        the key of the build setting.
        #
        # @param [String] value
        #        the value for the build setting.
        #
        # @return [void]
        #
        def set_setting(key, value)
          build_configurations.each do |bc|
            bc.build_settings[key] = value
          end
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
