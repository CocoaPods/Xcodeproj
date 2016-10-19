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

        def to_hash_as(method = :to_hash)
          super.tap do |hash|
            normalize_array_settings(hash['buildSettings'])
          end
        end

        # Sorts the build settings. Valid only in Ruby > 1.9.2 because in
        # previous versions the hash are not sorted.
        #
        # @return [void]
        #
        def sort(_options = nil)
          self.build_settings = sorted_build_settings
        end

        # @return [Boolean] Whether this configuration is configured for
        #         debugging.
        #
        def debug?
          gcc_preprocessor_definitions = build_settings['GCC_PREPROCESSOR_DEFINITIONS']
          gcc_preprocessor_definitions && gcc_preprocessor_definitions.include?('DEBUG=1')
        end

        # @return [Symbol] The symbolic type of this configuration, either
        #         `:debug` or `:release`.
        #
        def type
          debug? ? :debug : :release
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

        # yes, they are case-sensitive.
        # no, Xcode doesn't do this for other PathList settings nor other
        # settings ending in SEARCH_PATHS.
        ARRAY_SETTINGS = %w(
          ALTERNATE_PERMISSIONS_FILES
          ARCHS
          BUILD_VARIANTS
          EXCLUDED_SOURCE_FILE_NAMES
          FRAMEWORK_SEARCH_PATHS
          GCC_PREPROCESSOR_DEFINITIONS
          GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS
          HEADER_SEARCH_PATHS
          INFOPLIST_PREPROCESSOR_DEFINITIONS
          LIBRARY_SEARCH_PATHS
          OTHER_CFLAGS
          OTHER_CPLUSPLUSFLAGS
          OTHER_LDFLAGS
          REZ_SEARCH_PATHS
          SECTORDER_FLAGS
          WARNING_CFLAGS
          WARNING_LDFLAGS
        ).freeze
        private_constant :ARRAY_SETTINGS

        def normalize_array_settings(settings)
          return unless settings
          settings.keys.each do |key|
            next unless value = settings[key]
            case value
            when String
              next unless ARRAY_SETTINGS.include?(key)
              array_value = split_build_setting_array_to_string(value)
              next unless array_value.size > 1
              settings[key] = array_value
            when Array
              next if value.size > 1 && ARRAY_SETTINGS.include?(key)
              settings[key] = value.join(' ')
            end
          end
        end

        def split_build_setting_array_to_string(string)
          regexp = / *((['"]?).*?[^\\]\2)(?=( |\z))/
          string.scan(regexp).map(&:first)
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
