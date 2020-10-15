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

      def action_context?
        @xml_element.attributes['ActionContext']
      end

      def action_context=(ctx)
        return unless validate_action_context(ctx)

        @xml_element.delete_element('ActionContext')
        @xml_element.add_element(ctx.xml_element)
      end

      #-------------------------------------------------------------------------#

      private

      # @!group Private helpers

      def validate_action_type(type)
        return true unless @action_context

        if @action_context.is_a?(ShellScriptActionContext)
          type == Constants::EXECUTION_ACTION_TYPE[:shell_script_action]
        elsif @action_context.is_a?(SendEmailActionContext)
          type == Constants::EXECUTION_ACTION_TYPE[:send_email_action]
        else
          raise "[Xcodeproj] Invalid ActionType `#{type}` for ActionContext `#{@action_context.class}`"
        end
      end

      def validate_action_context(ctx)
        return true unless @action_type

        case @action_type
        when Constants::EXECUTION_ACTION_TYPE[:shell_script_action]
          ctx.is_a?(ShellScriptActionContext)
        when Constants::EXECUTION_ACTION_TYPE[:send_email_action]
          ctx.is_a?(SendEmailActionContext)
        else
          raise "[Xcodeproj] Invalid ActionContext `#{ctx.class}` for ActionType `#{@action_type}`"
        end
      end
    end
  end
end
