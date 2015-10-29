module Xcodeproj
  class Project
    module Object
      # Encapsulates the information a specific build configuration referenced
      # by a {XCConfigurationList} which in turn might be referenced by a
      # {PBXProject} or a {PBXNativeTarget}.
      #
      class XCBuildConfiguration < AbstractObject
        # @!group Attributes

        # @return [String] the name of the Target.
        #
        attribute :name, String

        # @return [Hash] the build settings to use for building the target.
        #
        attribute :build_settings, Hash, {}

        # @return [PBXFileReference] an optional file reference to a
        #         configuration file (`.xcconfig`).
        #
        has_one :base_configuration_reference, PBXFileReference

        public

        # @!group AbstractObject Hooks
        #---------------------------------------------------------------------#

        # @return [Hash{String => Hash}] A hash suitable to display the object
        #         to the user.
        #
        def pretty_print
          data = {}
          data['Build Settings'] = sorted_build_settings
          if base_configuration_reference
            data['Base Configuration'] = base_configuration_reference.pretty_print
          end
          { name => data }
        end

        # Sorts the build settings. Valid only in Ruby > 1.9.2 because in
        # previous versions the hash are not sorted.
        #
        # @return [void]
        #
        def sort(_options = nil)
          self.build_settings = sorted_build_settings
        end

        #---------------------------------------------------------------------#

        private

        def sorted_build_settings
          sorted = {}
          build_settings.keys.sort.each do |key|
            sorted[key] = build_settings[key]
          end
          sorted
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
