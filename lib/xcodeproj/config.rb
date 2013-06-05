module Xcodeproj

  # This class holds the data for a Xcode build settings file (xcconfig) and
  # provides support for serialization.
  #
  class Config

    require 'set'

    # @return [Hash{String => String}] The attributes of the settings file
    #         excluding frameworks, weak_framework and libraries.
    #
    attr_accessor :attributes

    # @return [Set<String>] The list of the frameworks required by this
    #         settings file.
    #
    attr_accessor :frameworks

    # @return [Set<String>] The list of the *weak* frameworks required by
    #         this settings file.
    #
    attr_accessor :weak_frameworks

    # @return [Set<String>] The list of the libraries required by this
    #         settings file.
    #
    attr_accessor :libraries

    # @return [Array] The list of the configuration files included by this
    #         configuration file (`#include "SomeConfig"`).
    #
    attr_accessor :includes

    # @param  [Hash, File, String] xcconfig_hash_or_file
    #         The initial data.
    #
    def initialize(xcconfig_hash_or_file = {})
      @attributes = {}
      @includes = []
      @frameworks, @weak_frameworks, @libraries = Set.new, Set.new, Set.new
      merge!(extract_hash(xcconfig_hash_or_file))
    end

    def inspect
      to_hash.inspect
    end

    def ==(other)
      other.respond_to?(:to_hash) && other.to_hash == self.to_hash
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Serialization

    # Sorts the internal data by setting name and serializes it in the xcconfig
    # format.
    #
    # @example
    #
    #   config = Config.new('PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2')
    #   config.to_s # => "OTHER_LDFLAGS = -lxml2\nPODS_ROOT = \"$(SRCROOT)/Pods\""
    #
    # @return [String] The serialized internal data.
    #
    def to_s(prefix = nil)
      [includes.map { |i| "#include \"#{i}\""} +
       to_hash(prefix).sort_by(&:first).map { |k, v| "#{k} = #{v}" }].join("\n")
    end

    # Writes the serialized representation of the internal data to the given
    # path.
    #
    # @param  [Pathname] pathname
    #         The file where the data should be written to.
    #
    # @return [void]
    #
    def save_as(pathname, prefix = nil)
      pathname.open('w') { |file| file << to_s(prefix) }
    end

    # The hash representation of the xcconfig. The hash includes the
    # frameworks, the weak frameworks and the libraries in the `Other Linker
    # Flags` (`OTHER_LDFLAGS`).
    #
    # @note   All the values are sorted to have a consistent output in Ruby
    #         1.8.7.
    #
    # @return [Hash] The hash representation
    #
    def to_hash(prefix = nil)
      hash = @attributes.dup
      flags = hash['OTHER_LDFLAGS'] || ''
      flags = flags.dup.strip
      flags << libraries.to_a.sort.reduce('')  {| memo, l | memo << " -l#{l}" }
      flags << frameworks.to_a.sort.reduce('') {| memo, f | memo << " -framework #{f}" }
      flags << weak_frameworks.to_a.sort.reduce('') {| memo, f | memo << " -weak_framework #{f}" }
      hash['OTHER_LDFLAGS'] = flags.strip
      hash.delete('OTHER_LDFLAGS') if flags.strip.empty?
      if prefix
        Hash[hash.map {|k, v| [prefix + k, v]}]
      else
        hash
      end
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Merging

    # Merges the given xcconfig representation in the receiver.
    #
    # @example
    #
    #   config = Config.new('PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2')
    #   config.merge!('OTHER_LDFLAGS' => '-lz', 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/Headers"')
    #   config.to_hash # => { 'PODS_ROOT' => '"$(SRCROOT)/Pods"', 'OTHER_LDFLAGS' => '-lxml2 -lz', 'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/Headers"' }
    #
    # @note   If a key in the given hash already exists in the internal data
    #         then its value is appended.
    #
    # @param  [Hash, Config] config
    #         The xcconfig representation to merge.
    #
    # @todo   The logic to normalize an hash should be extracted and the
    #         initializer should not call this method.
    #
    # @return [void]
    #
    def merge!(xcconfig)
      if xcconfig.is_a? Config
        @attributes.merge!(xcconfig.attributes) { |key, v1, v2| "#{v1} #{v2}" }
        @libraries.merge(xcconfig.libraries)
        @frameworks.merge(xcconfig.frameworks)
        @weak_frameworks.merge(xcconfig.weak_frameworks)
      else
        @attributes.merge!(xcconfig.to_hash) { |key, v1, v2| "#{v1} #{v2}" }
        # Parse frameworks and libraries. Then remove them from the linker
        # flags
        flags = @attributes['OTHER_LDFLAGS']
        return unless flags

        frameworks = flags.scan(/-framework\s+([^\s]+)/).map { |m| m[0] }
        weak_frameworks = flags.scan(/-weak_framework\s+([^\s]+)/).map { |m| m[0] }
        libraries  = flags.scan(/-l ?([^\s]+)/).map { |m| m[0] }
        @frameworks.merge frameworks
        @weak_frameworks.merge weak_frameworks
        @libraries.merge libraries

        new_flags = flags.dup
        frameworks.each {|f| new_flags.gsub!("-framework #{f}", "") }
        weak_frameworks.each {|f| new_flags.gsub!("-weak_framework #{f}", "") }
        libraries.each  {|l| new_flags.gsub!("-l#{l}", ""); new_flags.gsub!("-l #{l}", "") }
        @attributes['OTHER_LDFLAGS'] = new_flags.gsub("\w*", ' ').strip
      end
    end
    alias_method :<<, :merge!

    # Creates a new #{Config} with the data of the receiver merged with the
    # given xcconfig representation.
    #
    # @param  [Hash, Config] config
    #         The xcconfig representation to merge.
    #
    # @return [Config] the new xcconfig.
    #
    def merge(config)
      self.dup.tap { |x| x.merge!(config) }
    end

    # @return [Config] A copy of the receiver.
    #
    def dup
      Xcodeproj::Config.new(self.to_hash.dup)
    end

    #-------------------------------------------------------------------------#

    private

    # @!group Private Helpers

    # Returns a hash from the given argument reading it from disk if necessary.
    #
    # @param  [String, Pathname, Hash] argument
    #         The source from where the hash should be extracted.
    #
    # @return [Hash]
    #
    def extract_hash(argument)
      if argument.respond_to? :read
        hash_from_file_content(argument.read)
      elsif File.readable?(argument.to_s)
        hash_from_file_content(File.read(argument))
      else
        argument
      end
    end

    # Returns a hash from the string representation of an Xcconfig file.
    #
    # @param  [String] string
    #         The string representation of an xcconfig file.
    #
    # @return [Hash] the hash containing the xcconfig data.
    #
    def hash_from_file_content(string)
      hash = {}
      string.split("\n").each do |line|
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

    # Strips the comments from a line of an xcconfig string.
    #
    # @param  [String] line
    #         the line to process.
    #
    # @return [String] the uncommented line.
    #
    def strip_comment(line)
      line.partition('//').first
    end

    # Returns the file included by a line of an xcconfig string if present.
    #
    # @param  [String] line
    #         the line to process.
    #
    # @return [String] the included file.
    # @return [Nil] if no include was found in the line.
    #
    def extract_include(line)
      regexp = /#include\s*"(.+)"/
      match = line.match(regexp)
      match[1] if match
    end

    # Returns the key and the value described by the given line of an xcconfig.
    #
    # @param  [String] line
    #         the line to process.
    #
    # @return [Array] A tuple where the first entry is the key and the second
    #         entry is the value.
    #
    def extract_key_value(line)
      key, value = line.split('=', 2)
      if key && value
        [key.strip, value.strip]
      else
        []
      end
    end

    #-------------------------------------------------------------------------#

  end
end
