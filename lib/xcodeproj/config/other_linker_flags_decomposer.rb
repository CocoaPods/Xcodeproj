module Xcodeproj
  class Config
    module OtherLinkerFlagsDecomposer
      def self.decompose(flags)
        result = {
          :frameworks => [],
          :weak_frameworks => [],
          :libraries => [],
          :other => [],
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
              result[:other] << token
            end
          end
        end
        result
      end

      def self.tokenize(flags)
        result = []
        quotes_accumulator = nil

        candidates = flags.split(' ').map do |string|
          if string =~ /\A-l.+/
            ['-l', string[2..-1]]
          else
            string
          end
        end

        candidates.flatten.each do |candidate|
          if quotes_accumulator
            quotes_accumulator << ' ' << candidate
            if quotes_accumulator.end_with?('"')
              result << quotes_accumulator[0..-2]
              quotes_accumulator = nil
            end
          elsif candidate.start_with?('"')
            quotes_accumulator = candidate[1..-1]
          else
            result << candidate
          end
        end
        result
      end
    end
  end
end


