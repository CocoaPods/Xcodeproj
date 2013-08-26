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
            unless object.referrers.count == 1
              raise "[Xcodeproj] Consistency issue: unexpected multiple parents " \
                "for object `#{display name}`: "\
                "#{referrers.map(:display_name).join(', ')}"
            end
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
            source_tree + path
          end

          # @param  [PBXGroup, PBXFileReference] object
          #         The object to analyze.
          #
          # @return [Pathname] The absolute path of the source tree of the
          # object.
          #
          def source_tree_real_path(object)
            case object.source_tree
            when '<absolute>'
              Pathname.new('/')
            when '<group>'
              if parent(object).isa == 'PBXProject'
                object.project.path.dirname
              else
                real_path(parent(object))
              end
            when 'SOURCE_ROOT'
              object.project.path.dirname
            else
              raise "[Xcodeproj] Unable to compute the source tree for " \
                " `#{object.display_name}`: `#{object.source_tree}`"
            end
          end

          #-------------------------------------------------------------------#

        end
      end
    end
  end
end
