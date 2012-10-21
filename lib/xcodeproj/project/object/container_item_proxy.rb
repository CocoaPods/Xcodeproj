module Xcodeproj
  class Project
    module Object

      # Apparently a proxy for another object which might belong another
      # project contained in the same workspace of the project document.
      #
      # This class is referenced by {PBXTargetDependency}; for information
      # about it usage see the specs of that class.
      #
      # @note This class references the other objects by uuid instead of
      #       creating proper relationships because the other objects might be
      #       part of another project. This implies that the references to
      #       other objects should not increase the retain coutn of the
      #       targets.
      #
      # @todo: this class needs some work to support targets accross workspaces,
      #        as the container portal might not be initialized leading
      #        xcodproj to raise because ti can't find the UUID.
      #
      class PBXContainerItemProxy < AbstractObject

        # @return [String] apparently the UUID of the root object
        #   {PBXProject} of the project containing the represented object.
        #
        attribute :container_portal, String

        # @return [String] the type of the proxy.
        #
        # - {PBXNativeTarget} is `1`.
        #
        attribute :proxy_type, String

        # @return [String] apparently the UUID of the represented
        #   object.
        #
        # @note If the object is in another project this will return nil.
        #
        attribute :remote_global_id_string, String

        # @return [String] apparently the name of the object represented by
        #   the proxy.
        #
        attribute :remote_info, String

      end
    end
  end
end
