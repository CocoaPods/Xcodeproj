require 'open3'

require 'cfpropertylist'
# By default, the CFPropertyList gem will try to use the libxml-ruby backend,
# but this gem is causing segfaults and thus we don’t want that. Instead we try
# to use the Nokogiri backend, because that also has libxml bindings and does
# not lead to these segfaults.
#
# See https://github.com/CocoaPods/CocoaPods/issues/2483.
#
begin
  require 'cfpropertylist/rbNokogiriParser'
  def CFPropertyList.xml_parser_interface
    CFPropertyList::NokogiriXMLParser
  end
rescue LoadError
  require 'cfpropertylist/rbREXMLParser'
  def CFPropertyList.xml_parser_interface
    CFPropertyList::ReXMLParser
  end
end

module Xcodeproj
  # Provides support for loading and serializing property list files.
  #
  # @note We force CFPropertyList to automatically pick up the `nokogiri`
  #       strategy or fallback to `REXML` if unavailable.
  #
  module PlistHelper
    PLUTIL_BIN = '/usr/bin/plutil'

    class << self
      # Serializes a hash as an XML property list file.
      #
      # @param  [#to_hash] hash
      #         The hash to store.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def write(hash, path)
        unless hash.is_a?(Hash)
          if hash.respond_to?(:to_hash)
            hash = hash.to_hash
          else
            raise TypeError, "The given `#{hash}`, must be a hash or " \
              'respond to to_hash'
          end
        end

        unless path.is_a?(String) || path.is_a?(Pathname)
          raise TypeError, "The given `#{path}`, must be a string or " \
            'pathname'
        end
        plist = CFPropertyList::List.new
        options = { :convert_unknown_to_string => true }
        plist.value = CFPropertyList.guess(hash, options)

        if plutil_available?
          contents = plist.to_str(CFPropertyList::List::FORMAT_XML)
          plutil_save(contents, path)
        else
          plist.save(path, CFPropertyList::List::FORMAT_XML)
        end
      end

      # @return [String] Returns the native objects loaded from a property list
      #         file.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def read(path)
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
        `#{PLUTIL_BIN} -convert xml1 "#{path}" -o -`
      end

      # Saves a property to an XML file via the plutil tool.
      #
      # @param  [#to_s] contents.
      #         The contents of the property list.
      #
      # @param  [#to_s] path
      #         The path of the file.
      #
      def plutil_save(contents, path)
        Open3.popen3("#{PLUTIL_BIN} -convert xml1 -o '#{path}' -") do |stdin, stdout, _stderr|
          stdin.puts(contents)
          stdin.close
          stdout.read # Make Ruby 1.8.7 wait
        end
      end

      # @return [Bool] Whether the `plutil` tool is available.
      #
      def plutil_available?
        @plutil_available = File.executable?(PLUTIL_BIN) if @plutil_available.nil?
        @plutil_available
      end
    end
  end
end
