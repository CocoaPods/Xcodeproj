require 'xcodeproj/config/lexer'

module Xcodeproj
  class Config
    attr_accessor :settings

    class BuildSetting < Struct.new(:name, :value)
      class Field < Struct.new(:value, :defined_at)
        alias_method :to_s, :value

        class Location < Struct.new(:container, :line_number, :character_number)
        end
      end
    end

    module Parser
      # Container should be Pathname when from a xcconfig file, or a Xcodeproj::Project in case it's defined inside the project.
      def self.parse(input, container = nil)
        config = Config.new
        config.settings = []

        current_setting = nil
        Lexer.lex_config(input).each do |token|
          location = BuildSetting::Field::Location.new(container, token[:line_number], token[:character_number])
          field = BuildSetting::Field.new(token[:token], location)

          if current_setting.nil? && token[:type] == :setting
            current_setting = BuildSetting.new(field)
          elsif current_setting && token[:type] == :value
            current_setting.value = field
            config.settings << current_setting
            current_setting = nil
          else
            raise 'Parse error!'
          end
        end

        config
      end
    end
  end
end
