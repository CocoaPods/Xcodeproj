module Xcodeproj
  class XCScheme
    class ShellScriptActionContent < ActionContent
      def initialize(node = nil)
        super
        self.title = 'Run Script'
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
