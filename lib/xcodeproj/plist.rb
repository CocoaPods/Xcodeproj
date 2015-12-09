module Xcodeproj
  module Plist
    autoload :FFI, 'xcodeproj/plist/ffi'
    autoload :PlistGem, 'xcodeproj/plist/plist_gem'

    def self.read_from_path(path)
      path = path.to_s
      unless File.exist?(path)
        raise Informative, "The plist file at path `#{path}` doesn't exist."
      end
      if file_in_conflict?(path)
        raise Informative, "The file `#{path}` is in a merge conflict."
      end
      implementation.read_from_path(path)
    end

    def self.write_to_path(hash, path)
      if hash.respond_to?(:to_hash)
        hash = hash.to_hash
      else
        raise TypeError, "The given `#{hash.inspect}` must respond " \
                          "to #to_hash'."
      end

      unless path.is_a?(String) || path.is_a?(Pathname)
        raise TypeError, "The given `#{path}` must be a string or 'pathname'."
      end
      path = path.to_s
      raise IOError, 'Empty path.' if path.empty?
      implementation.write_to_path(hash, path)
    end

    POSSIBLE_IMPLEMENTATIONS = [:FFI, :PlistGem]

    class << self
      attr_accessor :implementation
      def implementation
        @implementation ||= autoload_implementation
      end
    end

    def self.autoload_implementation
      failures = POSSIBLE_IMPLEMENTATIONS.map do |impl|
        begin
          impl = Plist.const_get(impl)
          available = impl.available?
          return impl if available.is_a?(TrueClass)
          available
        rescue NameError, LoadError => e
          e.message
        end
      end
      failures.reject! { |i| i.is_a?(TrueClass) }
      raise Informative, "Unable to load a plist implementation:\n\n#{failures.join("\n\n")}"
    end

    # @return [Bool] Checks whether there are merge conflicts in the file.
    #
    # @param  [#to_s] path
    #         The path of the file.
    #
    def self.file_in_conflict?(path)
      file = File.open(path, 'r')
      file.each_line.any? { |l| l.match(/^(<|=|>){7}/) }
    ensure
      file.close
    end
  end
end
