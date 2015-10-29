module Xcodeproj
  class Project
    module Object
      # Represents a dependency of a target on another one.
      #
      class PBXTargetDependency < AbstractObject
        # @!group Attributes

        # @return [PBXNativeTarget] the target that needs to be built to
        #         satisfy the dependency.
        #
        has_one :target, AbstractTarget

        # @return [PBXContainerItemProxy] a proxy for the target that needs to
        #         be built.
        #
        # @note   Apparently to support targets in other projects of the same
        #         workspace.
        #
        has_one :target_proxy, PBXContainerItemProxy

        # @return [String] the name of the target.
        #
        # @note   This seems only to be used when the target dependency is a
        #         target from a nested Xcode project.
        #
        attribute :name, String

        public

        # @!group AbstractObject Hooks
        #--------------------------------------#

        # @return [String] The name of the dependency.
        #
        def display_name
          return name if name
          return target.name if target
          return target_proxy.remote_info if target_proxy
        end

        # @note This override is necessary because Xcode allows for circular
        #       target dependencies.
        #
        # @return [Hash<String => String>] Returns a cascade representation of
        #         the object without UUIDs.
        #
        def to_tree_hash
          hash = {}
          hash['displayName'] = display_name
          hash['isa'] = isa
          hash
        end

        # @note This is a no-op, because the targets could theoretically depend
        #   on each other, leading to a stack level too deep error.
        #
        # @see AbstractObject#sort_recursively
        #
        def sort_recursively(_options = nil)
        end
      end
    end
  end
end
