require 'xcodeproj/scheme/xml_element_wrapper'

module Xcodeproj
  class XCScheme
    # @return [Hash] Possible types for a scheme's 'ExecutionAction' node
    #
    EXECUTION_ACTION_TYPE = {
      :shell_script_action  => 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction',
      :send_email_action    => 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.SendEmailAction',
    }.freeze

    class ExecutionAction < XMLElementWrapper
      def initialize(action_type, node = nil)
        action_type_string_value = Constants::EXECUTION_ACTION_TYPE[action_type]
        raise "[Xcodeproj] Invalid ActionType: got `#{type}`" \
              " available `#{Constants::EXECUTION_ACTION_TYPE.keys}`" if action_type_string_value.nil?

        create_xml_element_with_fallback(node, 'ExecutionAction') do
          @xml_element.attributes['ActionType'] = action_type_string_value
        end
      end

      def action_type
        @xml_element.attributes['ActionType']
      end

      def action_context?
        @xml_element.attributes['ActionContext']
      end

      def action_context=(ctx)
        valid_context = case @action_type
                        when :shell_script_action
                          ctx.is_a?(ShellScriptActionContext)
                        when :send_email_action
                          ctx.is_a?(SendEmailActionContext)
                        else
                          false
                        end

        raise "[Xcodeproj] Invalid ActionContext `#{ctx.class}`" \
        " for current ActionType #{@action_type}, " unless valid_context

        @xml_element.delete_element('ActionContext')
        @xml_element.add_element(ctx.xml_element)
      end
    end
  end
end
