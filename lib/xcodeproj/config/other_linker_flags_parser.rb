require 'shellwords'

module Xcodeproj
  class Config
    # Parses other linker flags values.
    #
    module OtherLinkerFlagsParser

      #
      #
      def self.parse(flags)
        flags
        result = {
          :frameworks => [],
          :weak_frameworks => [],
          :libraries => [],
          :simple => [],
        }

        key = nil
        tokenize(flags).each do |token|
          case token
          when '-framework'
            key = :frameworks
          when '-weak_framework'
            key = :weak_frameworks
          when '-l'
            key = :libraries
          else
            if key
              result[key] << token
              key = nil
            else
              result[:simple] << token
            end
          end
        end
        result
      end

      def self.tokenize(flags)
        result = []
        quotes_accumulator = nil

        flags.strip.shellsplit.map do |string|
          if string =~ /\A-l.+/
            ['-l', string[2..-1]]
          else
            string
          end
        end.flatten
      end
    end
  end
end


