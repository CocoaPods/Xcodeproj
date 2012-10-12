module Xcodeproj
  class Project
    module Object

      # Contains the information about the build settings of a file used by an
      # {AbstractBuildPhase}.
      #
      class PBXBuildFile < AbstractObject

        # @return [Hash] the list of build settings for this file.
        #
        # The contents of this array depend on the phase of the build file.
        #
        # - For PBXHeadersBuildPhase is `{ "ATTRIBUTES" => [:value] }` where
        #   `:value` can be `Public`, `Private`, or nil (Protected).
        #
        attribute :settings, Hash, {}

        # @return [PBXFileReference] the file that to build.
        #
        has_one :file_ref, [PBXFileReference, PBXVariantGroup, XCVersionGroup]

      end
    end
  end
end
