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

      # @return [String]
      #         The launch automatically substyle
      #
      def launch_automatically_substyle
        @xml_element.attributes['launchAutomaticallySubstyle']
      end

      # @param [String] flag
      #        Set the launch automatically substyle ('2' for extensions)
      #
      def launch_automatically_substyle=(value)
        @xml_element.attributes['launchAutomaticallySubstyle'] = value.to_s
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

      # @return [EnvironmentVariables]
      #         Returns the EnvironmentVariables that will be defined at app launch
      #
      def environment_variables
        EnvironmentVariables.new(@xml_element.elements[XCScheme::VARIABLES_NODE])
      end

      # @param [EnvironmentVariables,nil] env_vars
      #        Sets the EnvironmentVariables that will be defined at app launch
      #
      def environment_variables=(env_vars)
        @xml_element.delete_element(XCScheme::VARIABLES_NODE)
        @xml_element.add_element(env_vars.xml_element) if env_vars
        env_vars
      end

      # @todo handle 'AdditionalOptions' tag

      # @return [CommandLineArguments]
      #         Returns the CommandLineArguments that will be passed at app launch
      #
      def command_line_arguments
        CommandLineArguments.new(@xml_element.elements[XCScheme::COMMAND_LINE_ARGS_NODE])
      end

      # @return [CommandLineArguments] arguments
      #         Sets the CommandLineArguments that will be passed at app launch
      #
      def command_line_arguments=(arguments)
        @xml_element.delete_element(XCScheme::COMMAND_LINE_ARGS_NODE)
        @xml_element.add_element(arguments.xml_element) if arguments
        arguments
      end
    end
  end
end
