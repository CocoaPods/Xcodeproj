module Xcodeproj
  class XCScheme
    class AnalyzeAction < XMLElementWrapper

      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'AnalyzeAction') do
          self.build_configuration = 'Debug'
        end
      end

      def build_configuration
        @xml_element.attributes['buildConfiguration']
      end

      def build_configuration=(config_name)
        @xml_element.attributes['buildConfiguration'] = config_name
      end
    end
  end
end