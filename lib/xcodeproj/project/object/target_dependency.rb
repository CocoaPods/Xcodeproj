module Xcodeproj
  class Project
    module Object

      # Represents a dependency of a target on another one.
      #
      class PBXTargetDependency < AbstractObject

        # @return [PBXNativeTarget] the target that needs to be built to
        #   satisfy the dependency.
        #
        has_one :target, AbstractTarget

        # @return [PBXContainerItemProxy] a proxy for the target that needs to
        #   be built. Apparently to support targets in other projects of the
        #   same workspace.
        #
        has_one :targetProxy, PBXContainerItemProxy

      end
    end
  end
end
