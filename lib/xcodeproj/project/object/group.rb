module Xcodeproj
  class Project
    module Object

      class AbstractGroupEntry < AbstractPBXObject
        has_one :group, :inverse_of => :children

        def initialize(project, uuid, attributes)
          is_new = uuid.nil?
          super
          # If there's no root_object yet, then this is probably the main group.
          if is_new && @project.root_object
            @project.main_group.children << self
          end
        end

        def destroy
          group.child_references.delete(uuid)
          super
        end
      end

      # @todo The `source_tree` can probably be more than just `<group>`.
      class PBXGroup < AbstractGroupEntry
        # [String] the source tree to which this group is relative. It can be
        #          `<group>`.
        attribute :source_tree

        has_many :children, :class => AbstractGroupEntry do |child|
          # Associating the AbstractGroupEntry instance to this group through
          # the inverse association will also remove it from the group it was
          # in.
          child.group = self
        end

        def initialize(*)
          super
          self.source_tree ||= '<group>'
          self.child_references ||= []
        end

        def main_group?
          @project.main_group.uuid == uuid
        end

        def name
          if name = super
            name
          elsif attributes.has_key?('path')
            File.basename(attributes['path'])
          elsif main_group?
            'Main Group'
          end
        end

        def files
          children.list_by_class(PBXFileReference)
        end

        def create_file(path)
          files.new("path" => path)
        end

        def create_files(paths)
          paths.map { |path| create_file(path) }
        end

        # @todo is this really useful?
        def file_with_path(path)
          files.where(:path => path)
        end

        def source_files
          children.list_by_class(PBXFileReference, lambda {
            files.reject { |file| file.build_files.empty? }.map(&:uuid)
          })
        end

        def groups
          children.list_by_class(PBXGroup)
        end

        def create_group(name)
          groups.new("name" => name)
        end

        def <<(child)
          children << child
        end
      end

    end
  end
end
