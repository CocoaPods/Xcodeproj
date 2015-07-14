require 'xcodeproj/scheme/xml_element_wrapper'

module Xcodeproj
  class XCScheme
    class AbstractSchemeAction < XMLElementWrapper
      def build_configuration
        @xml_element.attributes['buildConfiguration']
      end

      def build_configuration=(config_name)
        @xml_element.attributes['buildConfiguration'] = config_name
      end
    end
  end
end
