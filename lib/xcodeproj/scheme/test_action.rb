require 'xcodeproj/scheme/abstract_scheme_action'
require 'xcodeproj/scheme/environment_variables'

module Xcodeproj
  class XCScheme
    # This class wraps the TestAction node of a .xcscheme XML file
    #
    class TestAction < AbstractSchemeAction
      # @param [REXML::Element] node
      #        The 'TestAction' XML node that this object will wrap.
      #        If nil, will create a default XML node to use.
      #
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'TestAction') do
          @xml_element.attributes['selectedDebuggerIdentifier'] = 'Xcode.DebuggerFoundation.Debugger.LLDB'
          @xml_element.attributes['selectedLauncherIdentifier'] = 'Xcode.DebuggerFoundation.Launcher.LLDB'
          @xml_element.add_element('AdditionalOptions')
          self.should_use_launch_scheme_args_env = true
          self.build_configuration = 'Debug'
        end
      end

      # @return [Bool]
      #         Whether this Test Action should use the same arguments and environment variables
      #         as the Launch Action.
      #
      def should_use_launch_scheme_args_env?
        string_to_bool(@xml_element.attributes['shouldUseLaunchSchemeArgsEnv'])
      end

      # @param [Bool] flag
      #        Set whether this Test Action should use the same arguments and environment variables
      #        as the Launch Action.
      #
      def should_use_launch_scheme_args_env=(flag)
        @xml_element.attributes['shouldUseLaunchSchemeArgsEnv'] = bool_to_string(flag)
      end

      # @return [Bool]
      #         Whether Clang Code Coverage is enabled ('Gather coverage data' turned ON)
      #
      def code_coverage_enabled?
        string_to_bool(@xml_element.attributes['codeCoverageEnabled'])
      end

      # @rparam [Bool] flag
      #         Set whether Clang Code Coverage is enabled ('Gather coverage data' turned ON)
      #
      def code_coverage_enabled=(flag)
        @xml_element.attributes['codeCoverageEnabled'] = bool_to_string(flag)
      end

      # @return [Array<TestableReference>]
      #         The list of TestableReference (test bundles) associated with this Test Action
      #
      def testables
        return [] unless @xml_element.elements['Testables']

        @xml_element.elements['Testables'].get_elements('TestableReference').map do |node|
          TestableReference.new(node)
        end
      end

      # @param [TestableReference] testable
      #        Add a TestableReference (test bundle) to this Test Action
      #
      def add_testable(testable)
        testables = @xml_element.elements['Testables'] || @xml_element.add_element('Testables')
        testables.add_element(testable.xml_element)
      end

      # @return [Array<MacroExpansion>]
      #         The list of MacroExpansion bound with this TestAction
      #
      def macro_expansions
        @xml_element.get_elements('MacroExpansion').map do |node|
          MacroExpansion.new(node)
        end
      end

      # @param [MacroExpansion] macro_expansion
      #        Add a MacroExpansion to this TestAction
      #
      def add_macro_expansion(macro_expansion)
        @xml_element.add_element(macro_expansion.xml_element)
      end

      # @return [EnvironmentVariables]
      #         Returns the EnvironmentVariables that will be defined at test launch
      #
      def environment_variables
        EnvironmentVariables.new(@xml_element.elements[XCScheme::VARIABLES_NODE])
      end

      # @param [EnvironmentVariables,nil] env_vars
      #        Sets the EnvironmentVariables that will be defined at test launch
      # @return [EnvironmentVariables]
      #
      def environment_variables=(env_vars)
        @xml_element.delete_element(XCScheme::VARIABLES_NODE)
        @xml_element.add_element(env_vars.xml_element) if env_vars
        env_vars
      end

      #-------------------------------------------------------------------------#

      class TestableReference < XMLElementWrapper
        # @param [Xcodeproj::Project::Object::AbstractTarget, REXML::Element] target_or_node
        #        Either the Xcode target to reference,
        #        or an existing XML 'TestableReference' node element to reference,
        #        or nil to create an new, empty TestableReference
        #
        def initialize(target_or_node = nil)
          create_xml_element_with_fallback(target_or_node, 'TestableReference') do
            self.skipped = false
            add_buildable_reference BuildableReference.new(target_or_node) unless target_or_node.nil?
          end
        end

        # @return [Bool]
        #         Whether or not this TestableReference (test bundle) should be skipped or not
        #
        def skipped?
          string_to_bool(@xml_element.attributes['skipped'])
        end

        # @param [Bool] flag
        #        Set whether or not this TestableReference (test bundle) should be skipped or not
        #
        def skipped=(flag)
          @xml_element.attributes['skipped'] = bool_to_string(flag)
        end

        # @return [Array<BuildableReference>]
        #         The list of BuildableReferences this action will build.
        #         (The list usually contains only one element)
        #
        def buildable_references
          @xml_element.get_elements('BuildableReference').map do |node|
            BuildableReference.new(node)
          end
        end

        # @param [BuildableReference] ref
        #         The BuildableReference to add to the list of targets this action will build
        #
        def add_buildable_reference(ref)
          @xml_element.add_element(ref.xml_element)
        end

        # @todo handle 'AdditionalOptions' tag
      end
    end
  end
end
