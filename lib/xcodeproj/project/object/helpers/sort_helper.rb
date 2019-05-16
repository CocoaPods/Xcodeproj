module Xcodeproj
  # Wrapper for a string that sorts by name like Xcode does.
  # @example
  #   arrayOfFilenames.sort_by { |s| XcodeSortString.new(s) }
  class XcodeSortString
    include Comparable
    attr_reader :str_fallback, :ints_and_strings, :ints_and_strings_fallback, :str_pattern

    def initialize(str)
      # fallback pass
      @str_fallback = str
      # first pass: digits are used as integers, symbols are individualized, case is ignored
      @ints_and_strings = str.scan(/\d+|\p{L}+|[^\d\p{L}]/).map do |s|
        case s
        when /\d/ then Integer(s, 10)
        else
          if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.0')
            s.unicode_normalize(:nfkd).gsub(/\p{Mn}/, '').downcase
          else
            s.downcase
          end
        end
      end
      # second pass: digits are inverted, case is inverted
      @ints_and_strings_fallback = @str_fallback.scan(/\d+|\D+/).map do |s|
        case s
        when /\d/ then Integer(s.reverse, 10)
        else s.swapcase
        end
      end
      # comparing patterns: credit to https://rosettacode.org/wiki/Natural_sorting#Ruby
      @str_pattern = @ints_and_strings.map { |el| el.is_a?(Integer) ? :i : :s }.join
    end

    def <=>(other)
      if str_pattern.start_with?(other.str_pattern) || other.str_pattern.start_with?(str_pattern)
        compare = ints_and_strings <=> other.ints_and_strings
        if compare != 0
          # we sort naturally (literal ints, symbols individualized, case ignored)
          compare
        else
          # natural equality, we use the fallback sort (int reversed, case swapped)
          ints_and_strings_fallback <=> other.ints_and_strings_fallback
        end
      else
        # type mismatch, we sort alphabetically (case ignored)
        str_fallback.downcase <=> other.str_fallback.downcase
      end
    end
  end
end
