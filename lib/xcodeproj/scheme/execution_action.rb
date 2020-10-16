module Xcodeproj
  class XCScheme
    # This class wraps the ExecutionAction node of a .xcscheme XML file
    #
    class ExecutionAction < XMLElementWrapper
      # @param [REXML::Element] node
      #        The 'ExecutionAction' XML node that this object will wrap.
      #        If nil, will create an empty one
      #
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ExecutionAction')
      end

      # @return [String]
      #         The ActionType for this ExecutionAction.
      #         One of two values:
      #
      #         Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction,
      #         Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.SendEmailAction
      #
      def action_type
        @xml_element.attributes['ActionType']
      end

      # @param [String] value
      #         Set the ActionType for this ExecutionAction.
      #         One of two values:
      #
      #         Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction,
      #         Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.SendEmailAction
      #
      def action_type=(value)
        return unless validate_action_type(value)

        @xml_element.attributes['ActionType'] = value
      end

      # @return [ShellScriptActionContent]
      #         if action_type is 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction'
      #         returns the contents of the shell script to run pre/post action.
      #
      # @return [SendEmailActionContent]
      #         if action_type is 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.SendEmailAction'
      #         returns the contents of the email to send pre/post action.
      #
      def action_content
        @xml_element.attributes['ActionContent']
      end

      # @param [ShellScriptActionContent, SendEmailActionContent] value
      #        Set either the contents of the shell script to run pre/post action
      #        or the contents of the email to send pre/post action.
      #
      def action_content=(value)
        return unless validate_action_content(value)

        @xml_element.delete_element('ActionContent')
        @xml_element.add_element(value.xml_element)
      end

      #-------------------------------------------------------------------------#

      private

      # @!group Private helpers

      # @param [String] type
      #        Checks if type matches the expected action_content if present.
      #
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

      # @param [ShellScriptActionContent, SendEmailActionContent] value
      #        Checks if value matches the expected action_type if present.
      #
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
