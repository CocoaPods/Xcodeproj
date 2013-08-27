require 'xcodeproj/project/object/groupable_helper'

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

        # @return [String] the directory to which the path is relative.
        #
        # @note   The accepted values are:
        #         - `<absolute>` for absolute paths
        #         - `<group>` for paths relative to the group
        #         - `SOURCE_ROOT` for paths relative to the project
        #         - `DEVELOPER_DIR` for paths relative to the developer
        #           directory.
        #         - `BUILT_PRODUCTS_DIR` for paths relative to the build
        #           products directory.
        #         - `SDKROOT` for paths relative to the SDK directory.
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

        # @return [PBXGroup, PBXProject] the parent of the group.
        #
        def parent
          GroupableHelper.parent(self)
        end

        # @return [Pathname] the absolute path of the group resolving the
        # source tree.
        #
        def real_path
          GroupableHelper.real_path(self)
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

        # @return [Array<PBXGroup,PBXFileReference,PBXReferenceProxy>] the
        #         recursive children of the group.
        #
        def recursive_children_groups
          result = []
          groups.each do |child|
            result << child
            result.concat(child.recursive_children_groups)
          end
          result
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
        # @note   The subpath is created if needed, similar to the UNIX command
        #         `mkdir -p`
        #
        # @note   To closely match the Xcode behaviour the name attribute of
        #         the file reference is set only if the path of the file is not
        #         equal to the path of the group.
        #
        # @param  [#to_s] path
        #         the file system path of the file.
        #
        # @return [PBXFileReference] the new file reference.
        #
        def new_file(path)
          extname = File.extname(path)
          case
          when extname == '.framework' then new_framework(path)
          when extname == '.xcdatamodeld' then new_xcdatamodeld(path)
          else new_file_reference(path)
          end
        end

        # Creates a new file reference with the given path and adds it to the
        # group or to an optional subpath.
        #
        # @note   @see #new_file
        #
        # @param  @see #new_file
        #
        # @return [PBXFileReference] the new file reference.
        #
        def new_file_reference(path)
          ref = project.new(PBXFileReference)
          ref.path = path.to_s
          ref.update_last_known_file_type
          children << ref
          set_file_refenrece_name_if_needed(ref, self)
          ref
        end

        # Sets the name of a reference if needed, to match Xcode behaviour.
        #
        # @param  [PBXFileReference, XCVersionGroup] ref
        #         the reference which needs the name optionally set.
        #
        # @return [void]
        #
        def set_file_refenrece_name_if_needed(ref, parent_group)
          same_path_of_group = (parent_group.path == Pathname(ref.path).dirname.to_s)
          same_path_project = (Pathname(ref.path).dirname.to_s == '.' && parent_group.path.nil?)
          unless same_path_of_group || same_path_project
            ref.name = Pathname(ref.path).basename.to_s
          end
        end

        # Creates a new file reference to a framework bundle.
        #
        # @note   @see #new_file
        #
        # @param  @see #new_file
        #
        # @return [PBXFileReference] the new file reference.
        #
        def new_framework(path)
          ref = new_file_reference(path)
          ref.include_in_index = nil
          ref
        end

        # Creates a new version group reference to an xcdatamodeled adding the
        # xcdatamodel files included in the wrapper as children file references.
        #
        # @note  To match Xcode behaviour the last xcdatamodel according to its
        #        path is set as the current version.
        #
        # @note   @see #new_file
        #
        # @param  @see #new_file
        #
        # @return [XCVersionGroup] the new reference.
        #
        def new_xcdatamodeld(path)
          path = Pathname.new(path)
          ref = project.new(XCVersionGroup)
          ref.path = path.to_s
          ref.source_tree = '<group>'
          ref.version_group_type = 'wrapper.xcdatamodel'

          last_child_ref = nil
          if path.exist?
            path.children.each do |child_path|
              if File.extname(child_path) == '.xcdatamodel'
                child_ref = ref.new_file_reference(child_path)
                child_ref.source_tree = '<group>'
                last_child_ref = child_ref
              end
            end
            ref.current_version = last_child_ref
          end

          children << ref
          set_file_refenrece_name_if_needed(ref, self)
          ref
        end

        # Creates a new group with the given name and adds it to the children
        # of the group.
        #
        # @note   @see new_file
        #
        # @param  [#to_s] name
        #         the name of the new group.
        #
        # @return [PBXGroup] the new group.
        #
        def new_group(name)
          group = project.new(PBXGroup)
          group.name = name
          children << group
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
        # @return [PBXFileReference] the new file reference.
        #
        def new_static_library(product_name)
          file = new_file("lib#{product_name}.a")
          file.include_in_index = '0'
          file.source_tree = 'BUILT_PRODUCTS_DIR'
          file.explicit_file_type = file.last_known_file_type
          file.last_known_file_type = nil
          file
        end

        # Creates a file reference to a new bundle.
        #
        # @param  [#to_s] product_name
        #         the name of the bundle.
        #
        # @return [PBXFileReference] the new file reference.
        #
        def new_bundle(product_name)
          file = new_file("#{product_name}.bundle")
          file.explicit_file_type = 'wrapper.cfbundle'
          file.include_in_index = '0'
          file.source_tree = 'BUILT_PRODUCTS_DIR'
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
            else
              x.display_name <=> y.display_name
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
