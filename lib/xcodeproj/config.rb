module Xcodeproj
  # This class holds the data for a Xcode build settings file (xcconfig) and
  # serializes it.
  class Config
    # Returns a new instance of Config
    #
    # @param [Hash, File, String] xcconfig_hash_or_file  Initial data.
    require 'set'

    attr_accessor :attributes, :frameworks ,:libraries

    def initialize(xcconfig_hash_or_file = {})
      @attributes = {}
      @includes = []
      @frameworks, @libraries = Set.new, Set.new
      merge!(extract_hash(xcconfig_hash_or_file))
    end

    # @return [Hash] The internal data.
    def to_hash
      hash = @attributes.dup
      flags = hash['OTHER_LDFLAGS'] || ''
      flags = flags.dup.strip
      flags << libraries.to_a.sort.reduce('')  {| memo, l | memo << " -l#{l}" }
      flags << frameworks.to_a.sort.reduce('') {| memo, f | memo << " -framework #{f}" }
      hash['OTHER_LDFLAGS'] = flags.strip
      hash.delete('OTHER_LDFLAGS') if flags.strip.empty?
      hash
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
      if xcconfig.is_a? Config
        @attributes.merge!(xcconfig.attributes) { |key, v1, v2| "#{v1} #{v2}" }
        @libraries.merge   xcconfig.libraries
        @frameworks.merge  xcconfig.frameworks
      else
      @attributes.merge!(xcconfig.to_hash) { |key, v1, v2| "#{v1} #{v2}" }
      # Parse frameworks and libraries. Then remove the from the linker flags
      flags = @attributes['OTHER_LDFLAGS']
      return unless flags

      frameworks = flags.scan(/-framework\s+([^\s]+)/).map { |m| m[0] }
      libraries  = flags.scan(/-l ?([^\s]+)/).map { |m| m[0] }
      @frameworks.merge frameworks
      @libraries.merge libraries

      new_flags = flags.dup
      frameworks.each {|f| new_flags.gsub!("-framework #{f}", "") }
      libraries.each  {|l| new_flags.gsub!("-l#{l}", ""); new_flags.gsub!("-l #{l}", "") }
      @attributes['OTHER_LDFLAGS'] = new_flags.gsub("\w*", ' ').strip
      end
    end
    alias_method :<<, :merge!

    def merge(config)
      self.dup.tap { |x|x.merge!(config) }
    end

    def dup
      Xcodeproj::Config.new(self.to_hash.dup)
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
      to_hash.map { |key, value| "#{key} = #{value}" }.join("\n")
    end

    def inspect
      to_hash.inspect
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
