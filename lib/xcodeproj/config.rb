module Xcodeproj
  # This class holds the data for a Xcode build settings file (xcconfig) and
  # serializes it.
  class Config
    # Returns a new instance of Config
    #
    # @param [Hash, File, String] xcconfig_hash_or_file  Initial data.
    def initialize(xcconfig_hash_or_file = {})
      @attributes = {}
      @includes = []
      merge!(extract_hash(xcconfig_hash_or_file))
    end

    # @return [Hash] The internal data.
    def to_hash
      @attributes
    end

    def ==(other)
      other.respond_to?(:to_hash) && other.to_hash == self.to_hash
    end

    # @return [Array] Config's include file list
    # @example
    #
    # Consider following xcconfig file:
    #
    #   #include "SomeConfig"
    #   Key1 = Value1
    #   Key2 = Value2
    #
    #   config.includes # => [ "SomeConfig" ]
    def includes
      @includes
    end

    # Merges the given xcconfig hash or Config into the internal data.
    #
    # If a key in the given hash already exists, in the internal data, then its
    # value is appended to the value in the internal data.
    #
    # @example
    #
    #   config = Config.new('PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2')
    #   config.merge!('OTHER_LDFLAGS' => '-lz', 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/Headers"')
    #   config.to_hash # => { 'PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2 -lz', 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/Headers"' }
    #
    # @param [Hash, Config] xcconfig  The data to merge into the internal data.
    def merge!(xcconfig)
      @attributes.merge!(xcconfig.to_hash) { |key, v1, v2| "#{v1} #{v2}" }
    end
    alias_method :<<, :merge!

    def merge(config)
      self.dup.tap { |x|x.merge!(config) }
    end

    def dup
      Xcodeproj::Config.new(self.to_hash.dup)
    end

    def add_libraries(libraries)
      return if libraries.nil? || libraries.empty?
      flags = [ @attributes['OTHER_LD_FLAGS'] ] || []
      flags << "-l#{ libraries.join(' -l') }"
      @attributes['OTHER_LD_FLAGS'] = flags.compact.map(&:strip).join(' ')
    end

    def add_frameworks(frameworks)
      return if frameworks.nil? || frameworks.empty?
      flags = [ @attributes['OTHER_LD_FLAGS'] ] || []
      flags << "-framework #{ frameworks.join(' -framework ') }"
      @attributes['OTHER_LD_FLAGS'] = flags.compact.map(&:strip).join(' ')
    end

    # Serializes the internal data in the xcconfig format.
    #
    # @example
    #
    #   config = Config.new('PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2')
    #   config.to_s # => "PODS_ROOT = \"$(SRCROOT)/Pods\"\nOTHER_LDFLAGS = -lxml2"
    #
    # @return [String]  The serialized internal data.
    def to_s
      @attributes.map { |key, value| "#{key} = #{value}" }.join("\n")
    end

    def inspect
      @attributes.inspect
    end

    # Writes the serialized representation of the internal data to the given
    # path.
    #
    # @param [Pathname] pathname  The file that the data should be written to.
    def save_as(pathname)
      pathname.open('w') { |file| file << to_s }
    end

    private

    def extract_hash(argument)
      if argument.respond_to? :read
        hash_from_file_content(argument.read)
      elsif File.readable? argument.to_s
        hash_from_file_content(File.read(argument))
      else
        argument
      end
    end

    def hash_from_file_content(raw_string)
      hash = {}
      raw_string.split("\n").each do |line|
        uncommented_line = strip_comment(line)
        if include = extract_include(uncommented_line)
          @includes.push include
        else
          key, value = extract_key_value(uncommented_line)
          hash[key] = value if key
        end
      end
      hash
    end

    def strip_comment(line)
      line.partition('//').first
    end

    def extract_include(line)
      regexp = /#include\s*"(.+)"/
      match = line.match(regexp)
      match[1] if match
    end

    def extract_key_value(line)
      key, value = line.split('=', 2)
      if key && value
        [key.strip, value.strip]
      else
        []
      end
    end

  end
end
