require 'xcodeproj/scheme/xml_element_wrapper'
require 'xcodeproj/scheme/environment_variables'
require 'xcodeproj/scheme/command_line_arguments'

module Xcodeproj
  class XCScheme
    # This abstract class aims to be the base class for every XxxAction class
    # that have a #build_configuration attribute
    #
    class AbstractSchemeAction < XMLElementWrapper
      # @return [String]
      #         The build configuration associated with this action
      #         (usually either 'Debug' or 'Release')
      #
      def build_configuration
        @xml_element.attributes['buildConfiguration']
      end

      # @param [String] config_name
      #        The build configuration to associate with this action
      #        (usually either 'Debug' or 'Release')
      #
      def build_configuration=(config_name)
        @xml_element.attributes['buildConfiguration'] = config_name
      end
    end
  end
end
