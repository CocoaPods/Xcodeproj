module Xcodeproj
  # This class holds the data for a Xcode build settings file (xcconfig) and
  # serializes it.
  class Config
    # Returns a new instance of Config
    #
    # @param [Hash] xcconfig  Initial data.
    def initialize(xcconfig = {})
      @attributes = {}
      merge!(xcconfig)
    end

    # @return [Hash] The internal data.
    def to_hash
      @attributes
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
      xcconfig.to_hash.each do |key, value|
        if existing_value = @attributes[key]
          @attributes[key] = "#{existing_value} #{value}"
        else
          @attributes[key] = value
        end
      end
    end
    alias_method :<<, :merge!

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

    # Writes the serialized representation of the internal data to the given
    # path.
    #
    # @param [Pathname] pathname  The file that the data should be written to.
    def save_as(pathname)
      pathname.open('w') { |file| file << to_s }
    end
  end
end
