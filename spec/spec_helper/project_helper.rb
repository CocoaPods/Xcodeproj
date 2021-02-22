require 'colored2'

module SpecHelper
  module ProjectHelper
    # Keys which are excluded from comparison
    EXCLUDED_KEYS = %w(
      CODE_SIGN_ENTITLEMENTS
      IBSC_MODULE
      INFOPLIST_FILE
      IPHONEOS_DEPLOYMENT_TARGET
      MACOSX_DEPLOYMENT_TARGET
      PRODUCT_BUNDLE_IDENTIFIER
      SWIFT_VERSION
      TVOS_DEPLOYMENT_TARGET
      WATCHOS_DEPLOYMENT_TARGET
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
        missing_settings    = expected.keys.reject { |k| produced.key?(k) }
        unexpected_settings = produced.keys.reject { |k| expected.key?(k) }
        wrong_settings      = (expected.keys - missing_settings).select do |k|
          produced_setting = produced[k]
          produced_setting = produced_setting.join(' ') if produced_setting.respond_to? :join
          produced_setting != expected[k]
        end

        # Build pretty description for what is going on
        description = []
        description << "Doesn't match build settings for \e[1m#{params}\e[0m"

        if wrong_settings.count > 0
          description << 'Wrong build settings:'
          description += wrong_settings.map { |s| "* #{s.to_s.yellow} is #{produced[s].to_s.red}, but should be #{expected[s].to_s.green}" }
          description << ''
        end

        if missing_settings.count > 0
          description << 'Missing build settings:'
          description << missing_settings.map { |s| "* #{s.to_s.red} (#{expected[s]})" }
          description << ''
        end

        if unexpected_settings.count > 0
          description << 'Unexpected additional build settings:'
          description += unexpected_settings.map { |s| "* #{s.to_s.green} (#{produced[s]})" }
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
      project_defaults_by_config = Xcodeproj::Constants::PROJECT_DEFAULT_BUILD_SETTINGS
      project_defaults = project_defaults_by_config[:all]
      project_defaults.merge(project_defaults_by_config[type]) unless type == :base
      settings = apply_exclusions(settings, project_defaults)

      settings
    end

    # @!group Helper

    #-----------------------------------------------------------------------#

    # Exclude specific build settings from comparison.
    #
    # @param  [Hash{String => String}] settings
    #         the build settings, where to apply the exclusions.
    #
    # @param  [Array<String>, Hash{String => String}] exclusions
    #         the list of settings keys, which should been excluded.
    #
    # @return [Hash{String => String}]
    #         the filtered build settings
    #
    def apply_exclusions(settings, exclusions)
      by_value = !exclusions.is_a?(Array)
      settings.reject do |k, v|
        if by_value
          exclusions[k] == v
        else
          exclusions.include?(k)
        end
      end
    end
  end
end

class Bacon::Context
  def define(values)
    values.each do |key, value|
      define_singleton_method(key) { value }
    end
  end

  def should_raise_help(error_message)
    error = nil
    begin
      yield
    rescue CLAide::Help => e
      error = e
    end
    error.should.not.nil?
    error.error_message.should == error_message
  end
end
