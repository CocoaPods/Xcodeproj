require 'cfpropertylist'

module Xcodeproj
  # Provides support for loading and serializing property list files.
  #
  module PlistHelper
    class << self
      # Serializes a hash as a property list file.
      #
      # @param  [#to_hash] hash
      #         The hash to store.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def write_plist(hash, path)
        unless hash.is_a?(Hash)
          if hash.respond_to?(:to_hash)
            hash = hash.to_hash
          else
            raise TypeError, "The given #{hash}, must be a hash or respond to to_hash"
          end
        end
        plist = CFPropertyList::List.new
        plist.value = CFPropertyList.guess(hash, :convert_unknown_to_string => true)
        plist.save(path, CFPropertyList::List::FORMAT_XML)
      end

      # @return [String] Returns the native objects loaded from a property list
      #         file.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def read_plist(path)
        raise ArgumentError unless File.exist?(path)
        xml = plist_xml_contents(path)
        plist = CFPropertyList::List.new
        plist.load_xml_str(xml)
        CFPropertyList.native_types(plist.value)
      end

      private

      # @!group Private Helpers
      #---------------------------------------------------------------------#

      # @return [String] Returns the contents of a property list file with
      #         Converting it to XML using the `plutil` tool (if available).
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def plist_xml_contents(path)
        if plutil_available?
          `plutil -convert xml1 "#{path}" -o -`
        else
          File.read(path)
        end
      end

      # @return [Bool] Whether the `plutil` tool is available.
      #
      def plutil_available?
        `which plutil`
        $?.exitstatus.zero?
      end
    end
  end
end
