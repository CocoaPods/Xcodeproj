require 'colored'

module SpecHelper
  module ProjectHelper
    # Keys which are excluded from comparison
    EXCLUDED_KEYS = %w(
      INFOPLIST_FILE
      MACOSX_DEPLOYMENT_TARGET
      IPHONEOS_DEPLOYMENT_TARGET
    ).freeze

    # Generates test cases to compare two settings hashes.
    #
    # @param [Hash{String => String}] produced
    #        the produced build settings.
    #
    # @param [Hash{String => String}] expected
    #        the expected build settings.
    #
    # @param [#to_s] params
    #        the parameters used to construct the produced build settings.
    #
    def compare_settings(produced, expected, params)
      it 'should match build settings' do
        # Find faulty settings in different categories
        missing_settings    = expected.keys.select { |k| produced[k].nil? }
        unexpected_settings = produced.keys.select { |k| expected[k].nil? }
        wrong_settings      = (expected.keys - missing_settings).select do |k|
          produced_setting = produced[k]
          produced_setting = produced_setting.join(' ') if produced_setting.respond_to? :join
          produced_setting != expected[k]
        end

        # Build pretty description for what is going on
        description = []
        description << "Doesn't match build settings for #{params.to_s.bold}"

        if wrong_settings.count > 0
          description << 'Wrong build settings:'
          description += wrong_settings.map { |s| "* #{s.yellow} is #{produced[s].red}, but should be #{expected[s].green}" }
          description << ''
        end

        if missing_settings.count > 0
          description << 'Missing build settings:'
          description << missing_settings.map { |s| "* #{s.red}" }
          description << ''
        end

        if unexpected_settings.count > 0
          description << 'Unexpected additional build settings:'
          description += unexpected_settings.map { |s| "* #{s.green}" }
          description << ''
        end

        # Expect
        faulty_settings = missing_settings + unexpected_settings + wrong_settings
        faulty_settings.should.satisfy(description * "\n") do
          faulty_settings.length == 0
        end
      end
    end

    # Load settings from fixtures
    #
    # @param  [String] path
    #         the directory, where the fixture set is located.
    #
    # @param  [Symbol] type
    #         the type, where the specific
    #
    # @param  [Hash{String => String}]
    #         the build settings
    #
    def load_settings(path, type)
      # Load fixture
      base_path = Pathname(fixture_path("CommonBuildSettings/configs/#{path}"))
      config_fixture = base_path + "#{path}_#{type}.xcconfig"
      config = Xcodeproj::Config.new(config_fixture)
      settings = config.to_hash

      # Filter exclusions
      settings = apply_exclusions(settings, EXCLUDED_KEYS)
      settings = apply_exclusions(settings, Xcodeproj::Constants::PROJECT_DEFAULT_BUILD_SETTINGS[type != :base ? type : :all])

      settings
    end

    # @!group Helper

    #-----------------------------------------------------------------------#

    # Exclude specific build settings from comparison.
    #
    # @param  [Hash{String => String}] settings
    #         the build settings, where to apply the exclusions.
    #
    # @param  [Array<String>] exclusions
    #         the list of settings keys, which should been excluded.
    #
    # @return [Hash{String => String}]
    #         the filtered build settings
    #
    def apply_exclusions(settings, exclusions)
      settings.reject { |k, _| exclusions.include?(k) }
    end
  end
end

class Bacon::Context
  def define(values)
    values.each do |key, value|
      define_singleton_method(key) { value }
    end
  end
end
