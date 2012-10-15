module Xcodeproj
  class Project
    module Object

      # Apparently a proxy for another object which might belong another
      # project contained in the same workspace of the project document.
      #
      # This class is referenced by {PBXTargetDependency}; for information
      # about it usage see the specs of that class.
      #
      # @todo: this class needs some work to support targets accross workspaces,
      #        as the container portal might not be initialized leading
      #        xcodproj to raise because ti can't find the UUID.
      #
      class PBXContainerItemProxy < AbstractObject

        # @return [PBXProject] apparently the root object of the project
        #   containing the represented object.
        #
        has_one :container_portal, PBXProject

        # @return [String] the type of the proxy.
        #
        # - {PBXNativeTarget} is `1`.
        #
        attribute :proxy_type, String

        # @return [AbstractObject] apparently the UUID of the represented
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
