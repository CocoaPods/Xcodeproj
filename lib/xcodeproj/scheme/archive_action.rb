module Xcodeproj
  class XCScheme
    class ArchiveAction < XMLElementWrapper

      def initialize(node = nil)
        create_xml_element_with_fallback(node, 'ArchiveAction') do
          self.build_configuration = 'Release'
          self.reveal_archive_in_organizer = true
        end
      end

      def build_configuration
        @xml_element.attributes['buildConfiguration']
      end

      def build_configuration=(config_name)
        @xml_element.attributes['buildConfiguration'] = config_name
      end

      def reveal_archive_in_organizer?
        string_to_bool(@xml_element.attributes['revealArchiveInOrganizer'])
      end

      def reveal_archive_in_organizer=(flag)
        @xml_element.attributes['revealArchiveInOrganizer'] = bool_to_string(flag)
      end

      def custom_archive_name
        @xml_element.attributes['customArchiveName']
      end

      def custom_archive_name=(name)
        if name
          @xml_element.attributes['customArchiveName'] = name
        else
          @xml_element.delete_attribute('customArchiveName')
        end
      end
    end
  end
end