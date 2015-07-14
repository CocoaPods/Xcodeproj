module Xcodeproj
  class XCScheme
    class LaunchAction < XMLElementWrapper

      # @param [REXML::Element] node
      #
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'LaunchAction') do
          # Add some attributes (that are not handled by this wrapper class yet but expected in the XML)
          @xml_element.attributes['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
          @xml_element.attributes['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
          @xml_element.attributes['launchStyle'] = '0'
          @xml_element.attributes['useCustomWorkingDirectory'] = bool_to_string(false)
          @xml_element.attributes['ignoresPersistentStateOnLaunch'] = bool_to_string(false)
          @xml_element.attributes['debugDocumentVersioning'] = bool_to_string(true)
          @xml_element.attributes['debugServiceExtension'] = 'internal'
          @xml_element.add_element('AdditionalOptions')

          # Setup default values for other (handled) attributes
          self.build_configuration = 'Debug'
          self.allow_location_simulation = true
        end
      end

      def build_configuration
        @xml_element.attributes['buildConfiguration']
      end

      def build_configuration=(config_name)
        @xml_element.attributes['buildConfiguration'] = config_name
      end

      # @todo handle 'launchStyle' attribute
      # @todo handle 'useCustomWorkingDirectory attribute
      # @todo handle 'ignoresPersistentStateOnLaunch' attribute
      # @todo handle 'debugDocumentVersioning' attribute
      # @todo handle 'debugServiceExtension'

      def allow_location_simulation?
        string_to_bool(@xml_element.attributes['allowLocationSimulation'])
      end
      
      def allow_location_simulation=(flag)
        @xml_element.attributes['allowLocationSimulation'] = bool_to_string(flag)
      end

      # @return [BuildableProductRunnable]
      #         The BuildReference to launch when testing
      #
      def build_product_runnable
        BuildableProductRunnable.new(@xml_element.elements['BuildableProductRunnable'], 0)
      end

      # @param [BuildableProductRunnable] runnable
      #        The BuildableProductRunnable referencing the target to launch
      #
      def build_product_runnable=(runnable)
        @xml_element.delete_element('BuildableProductRunnable')
        @xml_element.add_element(runnable.xml_element) if runnable
      end

      # @todo handle 'AdditionalOptions' tag
    end
  end
end
