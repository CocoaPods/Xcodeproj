module Xcodeproj
  class Project
    module Object

      # This class represents a group. A group can contain other groups
      # (PBXGroup) and file references (PBXFileReference).
      #
      class PBXGroup < AbstractObject

        # @!group Attributes

        # @return [ObjectList<PBXGroup, PBXFileReference>]
        #         the objects contained by the group.
        #
        has_many :children, [PBXGroup, PBXFileReference, PBXReferenceProxy]

        # @return [String] the source tree to which this group is relative.
        #
        # @note   Usually is group <group>.
        #
        attribute :source_tree, String, '<group>'

        # @return [String] the path to a folder in the file system.
        #
        # @note   This attribute is present for groups that are linked to a
        #         folder in the file system.
        #
        attribute :path, String

        # @return [String] the name of the group.
        #
        # @note   If path is specified this attribute is not present.
        #
        attribute :name, String

        # @return [String] Whether Xcode should use tabs for text alignment.
        #
        # @example
        #   `1`
        #
        attribute :uses_tabs, String

        # @return [String] The width of the indent.
        #
        # @example
        #   `2`
        #
        attribute :indent_width, String

        # @return [String] The width of the tabs.
        #
        # @example
        #   `2`
        #
        attribute :tab_width, String

        # @return [String] Whether Xcode should wrap lines.
        #
        # @example
        #   `1`
        #
        attribute :wraps_lines, String

        # @return [String] Comments associated with this group.
        #
        # @note   This is apparently no longer used by Xcode.
        #
        attribute :comments, String

        #---------------------------------------------------------------------#

        public

        # @!group Helpers

        # @return [String] the name of the group taking into account the path
        #         or other factors if needed.
        #
        def display_name
          if name
            name
          elsif path
            File.basename(path)
          elsif self.equal?(project.main_group)
            'Main Group'
          end
        end

        # @return [Array<PBXFileReference>] the files references in the group
        #         children.
        #
        def files
          children.select { |obj| obj.class == PBXFileReference }
        end

        # @return [Array<PBXGroup>] the groups in the group children.
        #
        def groups
          children.select { |obj| obj.class == PBXGroup }
        end

        # @return [Array<XCVersionGroup>] the version groups in the group
        #         children.
        #
        def version_groups
          children.select { |obj| obj.class == XCVersionGroup }
        end

        # Creates a new file reference with the given path and adds it to the
        # group or to an optional subpath.
        #
        # @note The subpath is created if needed, similar to the UNIX command
        #       `mkdir -p`
        #
        # @param  [#to_s] path
        #         the file system path of the file.
        #
        # @param  [String] sub_group_path
        #         an optional subgroup path indicating the groups separated by
        #         a `/`.
        #
        # @return [PBXFileReference] the new file reference.
        #
        def new_file(path, sub_group_path = nil)
          file = project.new(PBXFileReference)
          file.path = path.to_s
          file.name = file.pathname.basename.to_s
          file.update_last_known_file_type

          target = find_subpath(sub_group_path, true)
          target.children << file
          file
        end

        # Creates a new group with the given name and adds it to the children
        # of the group.
        #
        # @note   @see new_file
        #
        # @param  [#to_s] name
        #         the name of the new group.
        #
        # @param  [String] sub_group_path @see new_file
        #
        # @return [PBXGroup] the new group.
        #
        def new_group(name, sub_group_path = nil)
          group = project.new(PBXGroup)
          group.name = name

          target = find_subpath(sub_group_path, true)
          target.children << group
          group
        end

        # Creates a file reference to a static library and adds it to the
        # children of the group.
        #
        # @note @see new_file
        #
        # @param  [#to_s] product_name
        #         the name of the new static library.
        #
        # @param  [String] sub_group_path @see new_file
        #
        # @return [PBXFileReference] the new group.
        #
        def new_static_library(product_name, sub_group_path = nil)
          file = new_file("lib#{product_name}.a", sub_group_path)
          file.include_in_index = '0'
          file.source_tree = 'BUILT_PRODUCTS_DIR'
          file.explicit_file_type = file.last_known_file_type
          file.last_known_file_type = nil
          file
        end

        # Creates a new group to represent a `xcdatamodel` file.
        #
        # @return [XCVersionGroup] The new group.
        #
        def new_xcdatamodel_group(xcdatamodel_path)
          g = @project.new(XCVersionGroup)
          g.path = xcdatamodel_path
          g.version_group_type = 'wrapper.xcdatamodel'
          file = g.new_file(xcdatamodel_path.sub(/xcdatamodeld$/, 'xcdatamodel'))
          g.current_version = file
          g
        end

        # Traverses the children groups and finds the group with the given
        # path, if exists.
        #
        # @see find_subpath
        #
        def [](path)
          find_subpath(path, false)
        end

        # Removes children files and groups under this group.
        #
        def remove_children_recursively
          groups.each do |g|
            g.remove_children_recursively
            g.remove_from_project
          end
          files.each { |f| f.remove_from_project }
        end

        # Traverses the children groups and finds the children with the given
        # path, optionally, creating any needed group. If the given path is
        # `nil` it returns itself.
        #
        # @param [String] path
        #   a string with the names of the groups separated by a '`/`'.
        #
        # @param [Boolean] should_create
        #   whether the path should be created.
        #
        # @note The path is matched against the {#display_name} of the groups.
        #
        # @example
        #   g = main_group['Frameworks']
        #   g.name #=> 'Frameworks'
        #
        # @return [PBXGroup] the group if found.
        # @return [Nil] if the path could not be found and should create is
        #         false.
        #
        def find_subpath(path, should_create = false)
          return self unless path
          path = path.split('/') unless path.is_a?(Array)
          child_name = path.shift
          child = children.find{ |c| c.display_name == child_name }
          if child.nil?
            if should_create
              child = new_group(child_name)
            else
              return nil
            end
          end
          if path.empty?
            child
          else
            child.find_subpath(path, should_create)
          end
        end

        # Adds an object to the group.
        #
        # @return [ObjectList<AbstractObject>] the children list.
        #
        def <<(child)
          children << child
        end

        # Sorts the children of the group by type and then by name.
        #
        # @note   This is safe to call in an object list because it modifies it
        #         in C in Ruby MRI. In other Ruby implementation it can cause
        #         issues if there is one call to the notification enabled
        #         methods not compensated by the corespondent opposite (loss of
        #         UUIDs and objects from the project).
        #
        # @return [void]
        #
        def sort_by_type!
          children.sort! do |x, y|
            if x.is_a?(PBXGroup) && y.is_a?(PBXFileReference)
              -1
            elsif x.is_a?(PBXFileReference) && y.is_a?(PBXGroup)
              1
            elsif x.respond_to?(:name) && y.respond_to?(:name)
              x.name <=> y.name
            else
              0
            end
          end
        end

      end

      #-----------------------------------------------------------------------#

      # This class is used to gather localized files into one entry.
      #
      class PBXVariantGroup < PBXGroup

        # @!group Attributes

        # @return [String] the file type guessed by Xcode.
        #
        attribute :last_known_file_type, String
      end

      #-----------------------------------------------------------------------#

      # A group that contains multiple files references to the different
      # versions of a resource.
      #
      # Used to contain the different versions of a `xcdatamodel`.
      #
      class XCVersionGroup < PBXGroup

        # @!group Attributes

        # @return [PBXFileReference] the reference to the current version.
        #
        has_one :current_version, PBXFileReference

        # @return [String] the type of the versioned resource.
        #
        attribute :version_group_type, String, 'wrapper.xcdatamodel'

      end

      #-----------------------------------------------------------------------#

    end
  end
end
