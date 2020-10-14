require 'xcodeproj/scheme/xml_element_wrapper'

module Xcodeproj
  class XCScheme
    class SendEmailActionContext < ActionContext
      attr_reader :archive_version

      def initialize(node = nil)
        super
        @title = 'Send Email'
        @attach_log_to_email = bool_to_string(false)
      end

      def email_recipient?
        @xml_element.attributes['emailRecipient']
      end

      def email_recipient=(value)
        @xml_element.attributes['emailRecipient'] = value
      end

      def email_subject?
        @xml_element.attributes['emailSubject']
      end

      def email_subject=(value)
        @xml_element.attributes['emailSubject'] = value
      end

      def email_body?
        @xml_element.attributes['emailBody']
      end

      def email_body=(value)
        @xml_element.attributes['emailBody'] = value
      end
    end
  end
end
