module Xcodeproj
  class XCScheme
    class TestAction < XMLElementWrapper
      # @param [REXML::Element] node
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

      def should_use_launch_scheme_args_env?
        string_to_bool(@xml_element.attributes['shouldUseLaunchSchemeArgsEnv'])
      end

      def should_use_launch_scheme_args_env=(flag)
        @xml_element.attributes['shouldUseLaunchSchemeArgsEnv'] = bool_to_string(flag)
      end

      def build_configuration
        @xml_element.attributes['buildConfiguration']
      end

      def build_configuration=(config_name)
        @xml_element.attributes['buildConfiguration'] = config_name
      end

      # @return [Array<TestableReference>]
      #
      def testables
        @xml_element.elements['Testables'].get_elements('TestableReference').map do |node|
          TestableReference.new(node)
        end
      end

      # @param [TestableReference] testable
      #
      def add_testable(testable)
        unless @xml_element.elements['Testables']
          @xml_element.add_element('Testables')
        end
        @xml_element.elements['Testables'].add_element(testable.xml_element)
      end

      # @return [Array<MacroExpansion>]
      #
      def macro_expansions
        @xml_element.get_elements('MacroExpansion').map do |node|
          MacroExpansion.new(node)
        end
      end

      # @param [MacroExpansion] macro_expansion
      #
      def add_macro_expansion(macro_expansion)
        @xml_element.add_element(macro_expansion.xml_element)
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

        def skipped?
          string_to_bool(@xml_element.attributes['skipped'])
        end

        def skipped=(flag)
          @xml_element.attributes['skipped'] = bool_to_string(flag)
        end

        # @return [Array<BuildableReference>]
        #
        def buildable_references
          @xml_element.get_elements('BuildableReference').map do |node|
            BuildableReference.new(node)
          end
        end

        # @param [BuildableReference] ref
        #
        def add_buildable_reference(ref)
          @xml_element.add_element(ref.xml_element)
        end

        # @todo handle 'AdditionalOptions' tag
      end
    end
  end
end
