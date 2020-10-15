module Xcodeproj
  class XCScheme
    class ShellScriptActionContent < XMLElementWrapper
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ActionContent') do
          self.title = 'Run Script'
        end
      end

      def title?
        @xml_element.attributes['title']
      end

      def title=(value)
        @xml_element.attributes['title'] = value
      end

      def script_text?
        @xml_element.attributes['scriptText']
      end

      def script_text=(value)
        @xml_element.attributes['scriptText'] = value
      end

      def shell_to_invoke?
        @xml_element.attributes['shellToInvoke']
      end

      def shell_to_invoke=(value)
        @xml_element.attributes['shellToInvoke'] = value
      end

      def buildable_reference?
        @xml_element.elements['EnvironmentBuildable'].attributes['BuildableReference']
      end

      def buildable_reference=(ref)
        @xml_element.delete_element('EnvironmentBuildable')

        env_buildable = @xml_element.add_element('EnvironmentBuildable')
        env_buildable.add_element(ref.xml_element)
      end
    end
  end
end
