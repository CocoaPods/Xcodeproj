module Xcodeproj
  class XCScheme
    # This class wraps a 'ActionContent' node of type
    # 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.SendEmailAction' of a .xcscheme XML file
    #
    class SendEmailActionContent < XMLElementWrapper
      # @return [Bool]
      #         Whether or not this action should attach log to email
      #
      attr_reader :attach_log_to_email
      alias attach_log_to_email? attach_log_to_email

      # @param [REXML::Element] node
      #        The 'ActionContent' XML node that this object will wrap.
      #        If nil, will create a default XML node to use.
      #
      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ActionContent') do
          @title = 'Send Email'
          # For some reason this is not visible in Xcode's UI and it's always set to 'NO'
          # couldn't find much documentation on it so it might be safer to keep it read only
          @attach_log_to_email = bool_to_string(false)
        end
      end

      # @return [String]
      #         The title of this ActionContent
      #
      def title
        @xml_element.attributes['title']
      end

      # @param [String] value
      #        Set the title of this ActionContent
      #
      def title=(value)
        @xml_element.attributes['title'] = value
      end

      # @return [String]
      #         The email recipient of this ActionContent
      #
      def email_recipient
        @xml_element.attributes['emailRecipient']
      end

      # @param [String]
      #        Set the email recipient of this ActionContent
      #
      def email_recipient=(value)
        @xml_element.attributes['emailRecipient'] = value
      end

      # @return [String]
      #         The email subject of this ActionContent
      #
      def email_subject
        @xml_element.attributes['emailSubject']
      end

      # @param [String]
      #        Set the email subject of this ActionContent
      #
      def email_subject=(value)
        @xml_element.attributes['emailSubject'] = value
      end

      # @return [String]
      #         The email body of this ActionContent
      #
      def email_body
        @xml_element.attributes['emailBody']
      end

      # @param [String]
      #        Set the email body of this ActionContent
      #
      def email_body=(value)
        @xml_element.attributes['emailBody'] = value
      end
    end
  end
end
