module Xcodeproj
  class XCScheme
    class ActionContent < XMLElementWrapper
      def initialize(target_or_node = nil)
        create_xml_element_with_fallback(target_or_node, 'ActionContent')
      end

      def title?
        @xml_element.attributes['title']
      end

      def title=(value)
        @xml_element.attributes['title'] = value
      end
    end
  end
end
