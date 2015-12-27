module Xcodeproj
  module Plist
    # @visibility private
    module PlistGem
      def self.attempt_to_load!
        return @attempt_to_load if defined?(@attempt_to_load)
        @attempt_to_load = begin
          require 'plist/parser'
          require 'plist/generator'
          nil
        rescue LoadError
          'Xcodeproj relies on a library called `plist` to read and write ' \
          'Xcode project files. Ensure you have the `plist` gem installed ' \
          'and try again.'
        end
      end

      def self.write_to_path(hash, path)
        ::Plist::Emit.save_plist(hash, path)
      end

      def self.read_from_path(path)
        ::Plist.parse_xml(path)
      end
    end
  end
end
