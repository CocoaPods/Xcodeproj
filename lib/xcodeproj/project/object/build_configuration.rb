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
          gcc_preprocessor_definitions = resolve_build_setting('GCC_PREPROCESSOR_DEFINITIONS')
          gcc_preprocessor_definitions && gcc_preprocessor_definitions.include?('DEBUG=1')
        end

        # @return [Symbol] The symbolic type of this configuration, either
        #         `:debug` or `:release`.
        #
        def type
          debug? ? :debug : :release
        end

        # @!group Helpers
        #---------------------------------------------------------------------#

        # Gets the value for the given build setting considering any configuration
        # file present and resolving inheritance between them
        #
        # @param [String] key
        #        the key of the build setting.
        #
        # @param [PBXNativeTarget] root_target
        #        use this to resolve complete recursion between project and targets
        #
        # @return [String] The value of the build setting
        #
        def resolve_build_setting(key, root_target = nil)
          setting = build_settings[key]
          setting = resolve_variable_substitution(setting, root_target) if setting.is_a?(String)
          config_setting = base_configuration_reference && config[key]
          config_setting = resolve_variable_substitution(config_setting, root_target) if config_setting.is_a?(String)

          project_setting = project.build_configuration_list[name]
          project_setting = nil if project_setting == self
          project_setting &&= project_setting.resolve_build_setting(key, root_target)

          [project_setting, config_setting, setting].compact.reduce do |inherited, value|
            expand_build_setting(value, inherited)
          end
        end

        #---------------------------------------------------------------------#

        private

        CAPTURE_VARIABLE_IN_BUILD_CONFIG = /
            \$ # matches dollar sign literally
            [{(] # matches a single caracter on this list
              ( # capture block
              [^inherited] # ignore if match characters in this list
              [$(){}_a-zA-Z0-9]*? # non-greedy lookup for everything that contains this list
              )
            [})] # matches a single caracter on this list
          /x

        def expand_build_setting(build_setting_value, config_value)
          default = build_setting_value.is_a?(String) ? '' : []
          inherited = config_value || default
          return build_setting_value.gsub(Regexp.union(Constants::INHERITED_KEYWORDS), inherited) if build_setting_value.is_a? String
          build_setting_value.map { |value| Constants::INHERITED_KEYWORDS.include?(value) ? inherited : value }.flatten
        end

        def resolve_variable_substitution(config_setting, root_target)
          variable = match_variable(config_setting)
          if variable.nil?
            return name if config_setting.eql?('CONFIGURATION')
            if root_target
              return root_target.build_configuration_list[name].resolve_build_setting(config_setting, root_target) || config_setting
            else
              return resolve_build_setting(config_setting, root_target) || config_setting
            end
          end
          resolve_variable_substitution(config_setting.sub(CAPTURE_VARIABLE_IN_BUILD_CONFIG, resolve_variable_substitution(variable, root_target)), root_target)
        end

        def match_variable(config_setting)
          match_data = config_setting.match(CAPTURE_VARIABLE_IN_BUILD_CONFIG)
          return match_data.captures.first unless match_data.nil?
          match_data
        end

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

        def config
          @config ||= Xcodeproj::Config.new(base_configuration_reference.real_path).to_hash.tap do |hash|
            normalize_array_settings(hash)
          end
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
