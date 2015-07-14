module Xcodeproj
  class XCScheme
    class BuildableProductRunnable < XMLElementWrapper
      # @param [Xcodeproj::Project::Object::AbstractTarget, REXML::Element] target_or_node
      #        Either the Xcode target to reference,
      #        or an existing XML 'BuildableProductRunnable' node element to reference
      #        or nil to create an new, empty BuildableProductRunnable
      #
      # @param [#to_s] runnable_debugging_mode
      #        The debugging mode (usually '0')
      #
      def initialize(target_or_node = nil, runnable_debugging_mode = nil)
        create_xml_element_with_fallback(target_or_node, 'BuildableProductRunnable') do
          self.buildable_reference = BuildableReference.new(target_or_node) if target_or_node
          @xml_element.attributes['runnableDebuggingMode'] = runnable_debugging_mode.to_s if runnable_debugging_mode
        end
      end

      def runnable_debugging_mode
        @xml_element.attributes['runnableDebuggingMode']
      end

      def runnable_debugging_mode=(value)
        @xml_element.attributes['runnableDebuggingMode'] = value.to_s
      end

      # @return [BuildableReference]
      #
      def buildable_reference
        @buildable_reference ||= BuildableReference.new @xml_element.elements['BuildableReference']
      end

      # @param [BuildableReference] ref
      #
      def buildable_reference=(ref)
        @xml_element.delete_element('BuildableReference')
        @xml_element.add_element(ref.xml_element)
        @buildable_reference = ref
      end
    end
  end
end
