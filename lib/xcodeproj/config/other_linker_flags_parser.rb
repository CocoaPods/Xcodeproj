require 'shellwords'

module Xcodeproj
  class Config
    # Parses other linker flags values.
    #
    module OtherLinkerFlagsParser
      # @return [Hash{Symbol, Array[String]}] Splits the given
      #         other linker flags value by type.
      #
      # @param  [String] flags
      #         The other linker flags value.
      #
      def self.parse(flags)
        result = {
          :frameworks => [],
          :weak_frameworks => [],
          :libraries => [],
          :simple => [],
          :force_load => [],
        }

        key = nil
        split(flags).each do |token|
          case token
          when '-framework'
            key = :frameworks
          when '-weak_framework'
            key = :weak_frameworks
          when '-l'
            key = :libraries
          when '-force_load'
            key = :force_load
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

      # @return [Array<String>] Split the given other linker
      #         flags value, taking into account quoting and
      #         the fact that the `-l` flag might omit the
      #         space.
      #
      # @param  [String] flags
      #         The other linker flags value.
      #
      def self.split(flags)
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
