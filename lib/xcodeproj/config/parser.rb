require 'xcodeproj/config/lexer'

module Xcodeproj
  class Config
    attr_accessor :settings

    class BuildSetting < Struct.new(:name, :value)
      class Field < Struct.new(:type, :content, :defined_at)
        class Location < Struct.new(:container, :line_number, :character_number)
        end
      end
    end

    module Parser
      def self.create_field(token, container)
        location = BuildSetting::Field::Location.new(container, token[:line_number], token[:character_number])
        BuildSetting::Field.new(token[:type], token[:token], location)
      end

      # Container should be Pathname when from a xcconfig file, or a Xcodeproj::Project in case it's defined inside the project.
      def self.parse(input, container = nil)
        config = Config.new
        config.settings = []

        current_setting = nil
        Lexer.lex_config(input).each do |token|
          next if token[:type] == :comment
          if current_setting.nil? && token[:type] == :setting
            current_setting = BuildSetting.new(create_field(token, container))
          elsif current_setting && token[:type] == :value
            value_fields = []
            Lexer.lex_value(token[:token]).each do |value_token|
              next if value_token[:type] == :space
              value_token[:line_number] = token[:line_number]
              # TODO eh, what's with the off by one?
              value_token[:character_number] += token[:character_number] - 1
              value_fields << create_field(value_token, container)
            end
            current_setting.value = value_fields
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
