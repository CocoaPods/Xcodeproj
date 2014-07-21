require 'cfpropertylist'

module Xcodeproj
  # Provides support for loading and serializing property list files.
  #
  module PlistHelper
    class << self
      # Serializes a hash as an XML property list file.
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
            raise TypeError, "The given `#{hash}`, must be a hash or " \
              "respond to to_hash"
          end
        end
        plist = CFPropertyList::List.new
        options = { :convert_unknown_to_string => true }
        plist.value = CFPropertyList.guess(hash, options)
        plist.save(path, CFPropertyList::List::FORMAT_XML)
      end

      # @return [String] Returns the native objects loaded from a property list
      #         file.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def read_plist(path)
        unless File.exist?(path)
          raise ArgumentError, "The file `#{path}` doesn't exists"
        end
        xml = plist_xml_contents(path)
        plist = CFPropertyList::List.new
        plist.load_xml_str(xml)
        CFPropertyList.native_types(plist.value)
      end

      private

      # @!group Private Helpers
      #-----------------------------------------------------------------------#

      # @return [String] Returns the contents of a property list file with
      #         Converting it to XML using the `plutil` tool if needed and
      #         available.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def plist_xml_contents(path)
        contents = File.read(path)
        if contents.include?('?xml')
          contents
        elsif plutil_available?
          plutil_contents(path)
        else
          raise "Unable to convert the `#{path}` plist file to XML"
        end
      end

      # @return [String] The contents of plist file normalized to XML via
      #         `plutil` tool.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      # @note   This method was extracted to simplify testing.
      #
      def plutil_contents(path)
        `plutil -convert xml1 "#{path}" -o -`
      end

      # @return [Bool] Whether the `plutil` tool is available.
      #
      def plutil_available?
        `which plutil`
        $?.exitstatus.zero?
        false
      end
    end
  end
end
