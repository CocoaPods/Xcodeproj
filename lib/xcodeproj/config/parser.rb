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
      # Container should be Pathname when from a xcconfig file, or a Xcodeproj::Project in case it's defined inside the project.
      def self.parse_config(input, container = nil)
        config = Config.new
        config.settings = parse_settings(input, container)
        config
      end

      def self.parse_value(input, container, character_number_offset = 0, line_number = nil)
        value_fields = []
        Lexer.lex_value(input).each do |token|
          next if token[:type] == :space
          token[:line_number] = line_number
          token[:character_number] += character_number_offset
          value_fields << create_field(token, container)
        end
        value_fields
      end

      private

      def self.parse_settings(input, container)
        settings = []
        current_setting = nil
        Lexer.lex_config(input).each do |token|
          next if token[:type] == :comment
          # Parse included xcconfig files
          if current_setting.nil? && token[:type] == :include && container.is_a?(Pathname)
            settings.concat(parse_settings_from_include(token[:token], container.dirname))
          # Start a new BuildSetting
          elsif current_setting.nil? && token[:type] == :setting
            current_setting = BuildSetting.new(create_field(token, container))
          # Parse a setting's value and assign it to the BuildSetting
          elsif current_setting && token[:type] == :value
            current_setting.value = parse_value(token[:token], container, token[:character_number] - 1, token[:line_number])
            settings << current_setting
            current_setting = nil
          else
            raise "Parse error at token: #{token.inspect}"
          end
        end
        settings
      end

      EXTNAME = '.xcconfig'

      # TODO relative and absolute paths
      def self.parse_settings_from_include(filename, relative_to_dir)
        filename << EXTNAME unless File.extname(filename) == EXTNAME
        path = relative_to_dir + filename
        parse_settings(File.read(path.to_s), path)
      end

      def self.create_field(token, container)
        location = BuildSetting::Field::Location.new(container, token[:line_number], token[:character_number])
        BuildSetting::Field.new(token[:type], token[:token], location)
      end
    end
  end
end
