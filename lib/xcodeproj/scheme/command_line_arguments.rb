require 'xcodeproj/scheme/xml_element_wrapper'

module Xcodeproj
  class XCScheme
    COMMAND_LINE_ARGS_NODE = 'CommandLineArguments'.freeze
    COMMAND_LINE_ARG_NODE = 'CommandLineArgument'.freeze

    # This class wraps the CommandLineArguments node of a .xcscheme XML file. This
    # is just a container of CommandLineArgument objects. It can either appear on a
    # LaunchAction or TestAction scheme group.
    #
    class CommandLineArguments < XMLElementWrapper
      # @param [nil,REXML::Element,Array<CommandLineArgument>,Array<Hash{Symbol => String,Bool}>] node_or_arguments
      #        The 'CommandLineArguments' XML node, or list of command line arguments, that this object represents.
      #          - If nil, an empty 'CommandLineArguments' XML node will be created
      #          - If an REXML::Element, it must be named 'CommandLineArguments'
      #          - If an Array of objects or Hashes, they'll each be passed to {#assign_argument}
      #
      def initialize(node_or_arguments = nil)
        create_xml_element_with_fallback(node_or_arguments, COMMAND_LINE_ARGS_NODE) do
          @all_arguments = []
          node_or_arguments.each { |var| assign_argument(var) } unless node_or_arguments.nil?
        end
      end

      # @return [Array<CommandLineArgument>]
      #         The key value pairs currently set in @xml_element
      #
      def all_arguments
        @all_arguments ||= @xml_element.get_elements(COMMAND_LINE_ARG_NODE).map { |argument| CommandLineArgument.new(argument) }
      end

      # Adds a given argument to the set of command line arguments, or replaces it if that key already exists
      #
      # @param [CommandLineArgument,Hash{Symbol => String,Bool}] argument
      #        The argument to add or update, backed by an CommandLineArgument node.
      #          - If an CommandLineArgument, the previous reference will still be valid
      #          - If a Hash, must conform to {CommandLineArgument#initialize} requirements
      # @return [Array<CommandLineArgument>]
      #         The new set of command line arguments after addition
      #
      def assign_argument(argument)
        env_var = argument.is_a?(CommandLineArgument) ? argument : CommandLineArgument.new(argument)
        all_arguments.each { |existing_var| remove_argument(existing_var) if existing_var.argument == env_var.argument }
        @xml_element.add_element(env_var.xml_element)
        @all_arguments << env_var
      end

      # Removes a specified argument (by string or object) from the set of command line arguments
      #
      # @param [CommandLineArgument,String] argument
      #        The argument to remove
      # @return [Array<CommandLineArgument>]
      #         The new set of command line arguments after removal
      #
      def remove_argument(argument)
        env_var = argument.is_a?(CommandLineArgument) ? argument : all_arguments.find { |var| var.argument == argument }
        raise "Unexpected parameter type: #{env_var.class}" unless env_var.is_a?(CommandLineArgument)
        @xml_element.delete_element(env_var.xml_element)
        @all_arguments -= [env_var]
      end

      # @param [String] key
      #        The key to lookup
      # @return [CommandLineArgument] argument
      #         Returns the matching command line argument for a specified key
      #
      def [](argument)
        all_arguments.find { |var| var.argument == argument }
      end

      # Assigns a value for a specified key
      #
      # @param [String] key
      #        The key to update in the command line arguments
      # @param [String] value
      #        The value to lookup
      # @return [CommandLineArgument] argument
      #         The newly updated command line argument
      #
      def []=(argument, enabled)
        assign_argument(:argument => argument, :enabled => enabled)
        self[argument]
      end

      # @return [Array<Hash{Symbol => String,Bool}>]
      #         The current command line arguments represented as an array
      #
      def to_a
        all_arguments.map(&:to_h)
      end
    end

    # This class wraps the CommandLineArgument node of a .xcscheme XML file.
    # Environment arguments are accessible via the NSDictionary returned from
    # [[NSProcessInfo processInfo] environment] in your app code.
    #
    class CommandLineArgument < XMLElementWrapper
      # @param [nil,REXML::Element,Hash{Symbol => String,Bool}] node_or_argument
      #        - If nil, it will create a default XML node to use
      #        - If a REXML::Element, should be a <CommandLineArgument> XML node to wrap
      #        - If a Hash, must contain keys :key and :value (Strings) and optionally :enabled (Boolean)
      #
      def initialize(node_or_argument)
        create_xml_element_with_fallback(node_or_argument, COMMAND_LINE_ARG_NODE) do
          raise "Must pass a Hash with 'argument' and 'enabled'!" unless node_or_argument.is_a?(Hash) &&
              node_or_argument.key?(:argument) && node_or_argument.key?(:enabled)

          @xml_element.attributes['argument'] = node_or_argument[:argument]
          @xml_element.attributes['isEnabled'] = if node_or_argument.key?(:enabled)
                                                   bool_to_string(node_or_argument[:enabled])
                                                 else
                                                   bool_to_string(false)
                                                 end
        end
      end

      # Returns the CommandLineArgument's key
      # @return [String]
      #
      def argument
        @xml_element.attributes['argument']
      end

      # Sets the CommandLineArgument's key
      # @param [String] key
      #
      def argument=(argument)
        @xml_element.attributes['argument'] = argument
      end

      # Returns the CommandLineArgument's enabled state
      # @return [Bool]
      #
      def enabled
        string_to_bool(@xml_element.attributes['isEnabled'])
      end

      # Sets the CommandLineArgument's enabled state
      # @param [Bool] enabled
      #
      def enabled=(enabled)
        @xml_element.attributes['isEnabled'] = bool_to_string(enabled)
      end

      # @return [Hash{:key => String, :value => String, :enabled => Bool}]
      #         The command line argument XML node with attributes converted to a representative Hash
      #
      def to_h
        { :argument => argument, :enabled => enabled }
      end
    end
  end
end
