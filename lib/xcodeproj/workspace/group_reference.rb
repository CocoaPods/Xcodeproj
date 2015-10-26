module Xcodeproj
  class Workspace
    # Describes a group reference of a Workspace.
    #
    class GroupReference
      # @return [String] the name of the group
      #
      attr_reader :name

      # @return [String] the type of reference to the project
      #
      # This can be of the following values:
      # - absolute
      # - group
      # - container (only supported value)
      # - developer
      #
      attr_reader :type

      # @param [#to_s] name @see name
      # @param [#to_s] type @see type
      #
      def initialize(name, type = 'container')
        @name = name.to_s
        @type = type.to_s
      end

      # @return [Bool] Whether a group reference is equal to another.
      #
      def ==(other)
        name == other.name && type == other.type
      end
      alias_method :eql?, :==

      # @return [Fixnum] A hash identical for equals objects.
      #
      def hash
        [name, type].hash
      end

      # Returns a group reference given XML representation.
      #
      # @param  [REXML::Element] xml_node
      #         the XML representation.
      #
      # @return [GroupReference] The new group reference instance.
      #
      def self.from_node(xml_node)
        type = xml_node.attribute('location').value.split(':', 2).first
        name = xml_node.attribute('name').value
        new(name, type)
      end

      # @return [REXML::Element] the XML representation of the group reference.
      #
      def to_node
        REXML::Element.new('Group').tap do |element|
          element.add_attribute('location', "#{type}:")
          element.add_attribute('name', "#{name}")
        end
      end
    end
  end
end
