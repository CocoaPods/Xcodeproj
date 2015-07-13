module Xcodeproj
  class XCScheme
    # Abstract base class used for scheme/* internal classes
    #
    class XMLElementWrapper
      attr_reader :xml_element

      def to_s
        formatter = XMLFormatter.new(2)
        formatter.compact = false
        out = ''
        formatter.write(@xml_element, out)
        out.gsub!("<?xml version='1.0' encoding='UTF-8'?>", '')
        out << "\n"
        out
      end

      def create_xml_element_with_fallback(node, tag_name)
        if node && node.is_a?(REXML::Element)
          raise Informative, 'Wrong XML tag name' unless node.name == tag_name
          @xml_element = node
        else
          @xml_element = REXML::Element.new(tag_name)
          yield if block_given?
        end
      end

      private

      def bool_to_string(flag)
        flag ? 'YES' : 'NO'
      end

      def string_to_bool(str)
        str == 'YES'
      end
    end
  end
end
