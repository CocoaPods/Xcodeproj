require 'xcodeproj/scheme/abstract_scheme_action'

module Xcodeproj
  class XCScheme
    # This class wraps the LaunchAction node of a .xcscheme XML file
    #
    class LaunchAction < AbstractSchemeAction
      # @param [REXML::Element] node
      #        The 'LaunchAction' XML node that this object will wrap.
      #        If nil, will create a default XML node to use.
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

      # @todo handle 'launchStyle' attribute
      # @todo handle 'useCustomWorkingDirectory attribute
      # @todo handle 'ignoresPersistentStateOnLaunch' attribute
      # @todo handle 'debugDocumentVersioning' attribute
      # @todo handle 'debugServiceExtension'

      # @return [Bool]
      #         Whether or not to allow GPS location simulation when launching this target
      #
      def allow_location_simulation?
        string_to_bool(@xml_element.attributes['allowLocationSimulation'])
      end

      # @param [Bool] flag
      #        Set whether or not to allow GPS location simulation when launching this target
      #
      def allow_location_simulation=(flag)
        @xml_element.attributes['allowLocationSimulation'] = bool_to_string(flag)
      end

      # @return [BuildableProductRunnable]
      #         The BuildReference to launch when executing the Launch Action
      #
      def buildable_product_runnable
        BuildableProductRunnable.new(@xml_element.elements['BuildableProductRunnable'], 0)
      end

      # @param [BuildableProductRunnable] runnable
      #        Set the BuildableProductRunnable referencing the target to launch
      #
      def buildable_product_runnable=(runnable)
        @xml_element.delete_element('BuildableProductRunnable')
        @xml_element.add_element(runnable.xml_element) if runnable
      end

      # @todo handle 'AdditionalOptions' tag
    end
  end
end
