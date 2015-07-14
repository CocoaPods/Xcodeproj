require 'xcodeproj/scheme/abstract_scheme_action'

module Xcodeproj
  class XCScheme
    class ProfileAction < AbstractSchemeAction
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ProfileAction') do
          # Add some attributes (that are not handled by this wrapper class yet but expected in the XML)
          @xml_element.attributes['savedToolIdentifier'] = ''
          @xml_element.attributes['useCustomWorkingDirectory'] = bool_to_string(false)
          @xml_element.attributes['debugDocumentVersioning'] = bool_to_string(true)

          # Setup default values for other (handled) attributes
          self.build_configuration = 'Release'
          self.should_use_launch_scheme_args_env = true
        end
      end

      def should_use_launch_scheme_args_env?
        string_to_bool(@xml_element.attributes['shouldUseLaunchSchemeArgsEnv'])
      end

      def should_use_launch_scheme_args_env=(flag)
        @xml_element.attributes['shouldUseLaunchSchemeArgsEnv'] = bool_to_string(flag)
      end

      # @return [BuildableProductRunnable]
      #         The BuildReference to launch when testing
      #
      def build_product_runnable
        BuildableProductRunnable.new @xml_element.elements['BuildableProductRunnable']
      end

      # @param [BuildableProductRunnable] runnable
      #         The BuildableProductRunnable referencing the target to launch when profiling
      #
      def build_product_runnable=(runnable)
        @xml_element.delete_element('BuildableProductRunnable')
        @xml_element.add_element(runnable.xml_element) if runnable
      end
    end
  end
end
