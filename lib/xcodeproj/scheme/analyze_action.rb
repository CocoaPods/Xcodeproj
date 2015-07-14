require 'xcodeproj/scheme/abstract_scheme_action'

module Xcodeproj
  class XCScheme
    class AnalyzeAction < AbstractSchemeAction
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'AnalyzeAction') do
          self.build_configuration = 'Debug'
        end
      end
    end
  end
end
