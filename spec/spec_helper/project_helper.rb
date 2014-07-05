module SpecHelper
  module ProjectHelper

    # Keys which are excluded from comparison
    EXCLUDED_KEYS = [
        'INFOPLIST_FILE',
        'MACOSX_DEPLOYMENT_TARGET',
        'IPHONEOS_DEPLOYMENT_TARGET',
    ].freeze

    # Generates test cases to compare two settings hashes.
    #
    # @param [Hash{String => String}] produced
    #        the produced build settings.
    #
    # @param [Hash{String => String}] expected
    #        the expected build settings.
    #
    def compare_settings(produced, expected)
      # Expect given settings
      expected.each do |key, value|
        it "should match setting #{key}" do
          produced[key].should.satisfy("#{key} should be '#{value}', but is #{produced[key] || 'missing'}.") do
            produced[key] == value
          end
        end
      end

      # Expect that no additional settings are set,
      # but if there are any, print a list which were not expected
      it 'should have no additional settings' do
        unexpected_settings = produced.keys.select { |k| expected[k] == nil }

        description = "Unexpected additional build settings:\n"
        description << unexpected_settings.map { |s| "* #{s}" } * "\n"

        unexpected_settings.should.satisfy(description) do
          unexpected_settings.length == 0
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

      return settings
    end

    private

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
      settings.reject { |k,_| exclusions.include?(k) }
    end

  end
end


module Xcodeproj
  class ParametrizedContext < Bacon::Context

    def initialize(*args, &block)
      @params = args.first.is_a?(Hash) ? args.shift : {}
      @name = args.unshift(@params.map { |k,v| "#{k} = #{v}" }.join(', ')).select { |s| s.to_s.length > 0 }.join(' ')
      @before, @after = [], []
      @block = Proc.new do
        @params.each { |k,v| class<<self; self end.send(:define_method, k) { v } }
        instance_eval(&block)
      end
    end

    def describe(*args, &block)
      # Instantiate sub-class, without joining args already, let's handle that our constructor
      context = self.class.new(*args, &block)
      (parent_context = self).methods(false).each {|e|
        class<<context; self end.send(:define_method, e) {|*args| parent_context.send(e, *args)}
      }
      @before.each { |b| context.before(&b) }
      @after.each { |b| context.after(&b) }
      context.run
    end

  end
end

module ProjectHelperSpecs
  # Extend each context with SpecHelper::ProjectHelper.
  def self.describe(*args, &block)
    Xcodeproj::ParametrizedContext.new(*args, &block).run
  end
end
