module Xcodeproj
  class XCScheme
    class ExecutionAction < XMLElementWrapper
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ExecutionAction')
      end

      def action_type?
        @xml_element.attributes['ActionType']
      end

      def action_type=(value)
        return unless validate_action_type(value)

        @xml_element.attributes['ActionType'] = value
      end

      def action_content?
        @xml_element.attributes['ActionContent']
      end

      def action_content=(value)
        return unless validate_action_content(value)

        @xml_element.delete_element('ActionContent')
        @xml_element.add_element(value.xml_element)
      end

      #-------------------------------------------------------------------------#

      private

      # @!group Private helpers

      def validate_action_type(type)
        return true unless @action_content

        if @action_content.is_a?(ShellScriptActionContent)
          type == Constants::EXECUTION_ACTION_TYPE[:shell_script_action]
        elsif @action_content.is_a?(SendEmailActionContent)
          type == Constants::EXECUTION_ACTION_TYPE[:send_email_action]
        else
          raise "[Xcodeproj] Invalid ActionType `#{type}` for ActionContent `#{@action_content.class}`"
        end
      end

      def validate_action_content(value)
        return true unless @action_type

        case @action_type
        when Constants::EXECUTION_ACTION_TYPE[:shell_script_action]
          value.is_a?(ShellScriptActionContent)
        when Constants::EXECUTION_ACTION_TYPE[:send_email_action]
          value.is_a?(SendEmailActionContent)
        else
          raise "[Xcodeproj] Invalid ActionContent `#{value.class}` for ActionType `#{@action_type}`"
        end
      end
    end
  end
end
