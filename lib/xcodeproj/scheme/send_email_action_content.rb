module Xcodeproj
  class XCScheme
    class SendEmailActionContent < XMLElementWrapper
      attr_reader :attach_log_to_email

      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ActionContent') do
          @title = 'Send Email'
          # For some reason this is not visible in Xcode's UI and it's always set to 'NO'
          # couldn't find much documentation on it so it might be safer to keep it read only
          @attach_log_to_email = bool_to_string(false)
        end
      end

      def title?
        @xml_element.attributes['title']
      end

      def title=(value)
        @xml_element.attributes['title'] = value
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
