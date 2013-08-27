module Xcodeproj
  class Project
    module Object
      class GroupableHelper
        class << self

          # @param  [PBXGroup, PBXFileReference] object
          #         The object to analyze.
          #
          # @return [PBXGroup, PBXProject] The parent of the object.
          #
          def parent(object)
            check_parents_integrity(object)
            object.referrers.first
          end

          # @param  [PBXGroup, PBXFileReference] object
          #         The object to analyze.
          #
          # @return [Pathname] The absolute path of the object resolving the
          #         source tree.
          #
          def real_path(object)
            source_tree = source_tree_real_path(object)
            path = object.path || ''
            if source_tree
              source_tree + path
            else
              Pathname(path)
            end
          end

          # @param  [PBXGroup, PBXFileReference] object
          #         The object to analyze.
          #
          # @return [Pathname] The absolute path of the source tree of the
          #         object.
          #
          def source_tree_real_path(object)
            case object.source_tree
            when '<group>'
              if parent(object).isa == 'PBXProject'
                object.project.path.dirname
              else
                real_path(parent(object))
              end
            when 'SOURCE_ROOT'
              object.project.path.dirname
            when '<absolute>', 'BUILT_PRODUCTS_DIR', 'DEVELOPER_DIR'
              nil
            else
              raise "[Xcodeproj] Unable to compute the source tree for " \
                " `#{object.display_name}`: `#{object.source_tree}`"
            end
          end

          # @return [Hash{Symbol => String}] The source tree values by they
          #         symbol representation.
          #
          SOURCE_TREES_BY_KEY = {
            :absolute        => '<absolute>',
            :group           => '<group>',
            :project         => 'SOURCE_ROOT',
            :built_products  => 'BUILT_PRODUCTS_DIR',
            :developer_dir   => 'DEVELOPER_DIR',
            :sdk_root        => 'SDKROOT',
          }

          # Sets the path of the given object according to the provided source
          # tree key. The path is converted to relative according to the real
          # path of the source tree for group and project source trees, if both
          # paths are relative or absolute. Otherwise the path is set as
          # provided.
          #
          # @param  [PBXGroup, PBXFileReference] object
          #         The object whose path needs to be set.
          #
          # @param  [#to_s] path
          #         The path.
          #
          # @param  [Symbol] source_tree_key
          #         The source tree type, see {SOURCE_TREES_BY_KEY} for
          #         acceptable values.
          #
          # @return [void]
          #
          def set_path_with_source_tree(object, path, source_tree_key)
            path = Pathname.new(path)
            source_tree = SOURCE_TREES_BY_KEY[source_tree_key]
            object.source_tree = source_tree

            unless source_tree
              raise "[Xcodeproj] Unrecognized source tree option `#{source_tree_key}` for path `#{path}`"
            end

            if source_tree_key == :absolute
              unless path.absolute?
                raise "[Xcodeproj] Attempt to set a relative path with an " \
                  "absolute source tree: `#{path}`"
              end
              object.path = path.to_s
            elsif source_tree_key == :group || source_tree_key == :project
              source_tree_real_path = GroupableHelper.source_tree_real_path(object)
              if source_tree_real_path && source_tree_real_path.absolute? == path.absolute?
                relative_path = path.relative_path_from(source_tree_real_path)
                object.path = relative_path.to_s
              else
                object.path = path.to_s
              end
            else
              object.path = path.to_s
            end
          end

          private

          # @group Helpers
          #-------------------------------------------------------------------#

          # Checks whether there is a single identifiable parent and raises
          # otherwise.
          #
          # @return [void]
          #
          def check_parents_integrity(object)
            referrers_count = object.referrers.count
            if referrers_count > 1
              referrers_count = object.referrers.reject{ |obj| obj.isa == 'PBXProject' }.count
            end

            if referrers_count == 0
              raise "[Xcodeproj] Consistency issue: no parent " \
                "for object `#{object.display_name}`: "\
                "#{object.referrers}"
            elsif referrers_count > 1
              raise "[Xcodeproj] Consistency issue: unexpected multiple parents " \
                "for object `#{object.display_name}`: "\
                "#{object.referrers}"
            end
          end

          #-------------------------------------------------------------------#

        end
      end
    end
  end
end
