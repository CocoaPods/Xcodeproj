require 'xcodeproj/scheme/abstract_scheme_action'

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

        # @return [Array<SkippedTest>]
        #         The list of SkippedTest this action will skip.
        #
        def skipped_tests
          return [] if @xml_element.elements['SkippedTests'].nil?
          @xml_element.elements['SkippedTests'].get_elements('Test').map do |node|
            TestableReference::SkippedTest.new(node)
          end
        end

        # @param [Array<SkippedTest>] tests
        #         Set the list of SkippedTest this action will skip.
        #
        def skipped_tests=(tests)
          @xml_element.delete_element('SkippedTests') unless @xml_element.elements['SkippedTests'].nil?
          if tests.nil?
            return
          end
          entries = @xml_element.add_element('SkippedTests')
          tests.each do |skipped|
            entries.add_element(skipped.xml_element)
          end
        end

        # @param [SkippedTest] skipped_test
        #         The SkippedTest to add to the list of tests this action will skip
        #
        def add_skipped_test(skipped_test)
          entries = @xml_element.elements['SkippedTests'] || @xml_element.add_element('SkippedTests')
          entries.add_element(skipped_test.xml_element)
        end

        class SkippedTest < XMLElementWrapper
          # @param [REXML::Element] node
          #        The 'Test' XML node that this object will wrap.
          #        If nil, will create a default XML node to use.
          #
          def initialize(node = nil)
            create_xml_element_with_fallback(node, 'Test') do
              self.identifier = node.attributes['Identifier'] unless node.nil?
            end
          end

          # @return [String]
          #         Skipped test class name
          #
          def identifier
            @xml_element.attributes['Identifier']
          end

          # @param [String] value
          #        Set the name of the skipped test class name
          #
          def identifier=(value)
            @xml_element.attributes['Identifier'] = value
          end
        end

        # @todo handle 'AdditionalOptions' tag
      end
    end
  end
end
