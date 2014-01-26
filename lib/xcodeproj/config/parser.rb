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

      # Container should be Pathname when from a xcconfig file, or a Xcodeproj::Project in case it's defined inside the project.
      def self.parse(input, container = nil)
        config = Config.new
        config.settings = []

        current_setting = nil
        Lexer.lex_config(input).each do |token|
          next if token[:type] == :comment
          if current_setting.nil? && token[:type] == :include && container.is_a?(Pathname)
            # TODO
            # * relative and absolute paths
            # * with or without xcconfig extname
            path = container.dirname + token[:token]
            c = parse(File.read(path.to_s), path)
            config.settings.concat(c.settings)
          elsif current_setting.nil? && token[:type] == :setting
            current_setting = BuildSetting.new(create_field(token, container))
          elsif current_setting && token[:type] == :value
            current_setting.value = parse_value(token[:token], container, token[:character_number] - 1, token[:line_number])
            config.settings << current_setting
            current_setting = nil
          else
            raise "Parse error at token: #{token.inspect}"
          end
        end

        config
      end

      private

      def self.create_field(token, container)
        location = BuildSetting::Field::Location.new(container, token[:line_number], token[:character_number])
        BuildSetting::Field.new(token[:type], token[:token], location)
      end
    end
  end
end
