module Xcodeproj
  class Project
    module Object

      # The primary purpose of this class is to maintain a collection of
      # related build configurations of a {PBXProject} or a {PBXNativeTarget}.
      #
      class XCConfigurationList < AbstractObject

        # @!group Attributes

        # @return [String] whether the default configuration is visible.
        #
        # Usually `0`.
        #
        attribute :default_configuration_is_visible, String, '0'

        # @return [String] the name of the default configuration.
        #
        # Usually `Release`.
        #
        attribute :default_configuration_name, String

        # @return [ObjectList<XCBuildConfiguration>] the build
        #   configurations of the target.
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
        #   the name of the build configuration.
        #
        # @return [Hash {String=>String}] the build settings
        #
        def build_settings(build_configuration_name)
          if config = self[build_configuration_name]
            config.build_settings
          end
        end

        #---------------------------------------------------------------------#

      end
    end
  end
end
