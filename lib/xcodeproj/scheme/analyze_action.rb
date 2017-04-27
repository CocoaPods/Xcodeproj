require 'xcodeproj/scheme/abstract_scheme_action'

module Xcodeproj
  class XCScheme
    # This class wraps the AnalyzeAction node of a .xcscheme XML file
    #
    class AnalyzeAction < AbstractSchemeAction
      # @param [XScheme] scheme
      #        The scheme this element belongs to.
      #
      # @param [REXML::Element] node
      #        The 'AnalyzeAction' XML node that this object will wrap.
      #        If nil, will create a default XML node to use.
      #
      def initialize(scheme, node = nil)
        create_xml_element_with_fallback(node, 'AnalyzeAction', scheme) do
          self.build_configuration = 'Debug'
        end
      end
    end
  end
end
