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
        has_one :targetProxy, PBXContainerItemProxy

        # @return [String] the name of the target.
        #
        # @note   This seems only to be used when the target dependency is a
        #         target from a nested Xcode project.
        #
        attribute :name, String
      end
    end
  end
end
