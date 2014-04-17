module Xcodeproj
  class Workspace
    class FileReference
      # @return [String] the path to the project
      #
      attr_reader :path

      # @return [String] the type of reference to the project
      #
      # This can be of the following values:
      # - absolute
      # - group
      # - container
      # - developer (unsupported)
      attr_reader :type

      def self.from_node(node)
        type, path = node.attribute('location').value.split(':', 2)
        new(path, type)
      end

      def initialize(path, type=nil)
        @path = path
        @type = type || "group"
      end

      def ==(other)
        @path == other.path && @type == other.type
      end

      def to_node
        REXML::Element.new("FileRef").tap do |element|
          element.attributes['location'] = "#{@type}:#{@path}"
        end
      end

      # Get the absolute path to a project in a workspace
      #
      # @param [String] workspace_dir_path
      #         path of workspaces dir
      #
      # @return [String] The absolute path to the project
      #
      def absolute_path(workspace_dir_path)
        case @type
        when 'group'
          File.expand_path(File.join(workspace_dir_path, @path))
        when 'container'
          File.expand_path(File.join(workspace_dir_path, @path))
        when 'absolute'
          File.expand_path(@path)
        when 'developer'
          # TODO
          raise "Developer file reference type is not yet supported"
        else
          raise "Unsupported workspace file reference type #{@type}"
        end
      end
    end
  end
end
