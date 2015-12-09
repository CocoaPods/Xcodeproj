module Xcodeproj
  module Plist
    module PlistGem
      def self.available?
        @available ||= begin
          require 'plist/parser'
          require 'plist/generator'
          true
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
