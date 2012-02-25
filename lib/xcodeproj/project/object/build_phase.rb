module Xcodeproj
  class Project
    module Object

      class PBXBuildFile < PBXObject
        attributes :settings
        has_one :file, :uuid => :fileRef
      end

      class PBXBuildPhase < PBXObject
        # TODO rename this to buildFiles and add a files :through => :buildFiles shortcut
        has_many :files, :class => PBXBuildFile

        attributes :buildActionMask, :runOnlyForDeploymentPostprocessing

        def initialize(*)
          super
          self.fileReferences ||= []
          # These are always the same, no idea what they are.
          self.buildActionMask ||= "2147483647"
          self.runOnlyForDeploymentPostprocessing ||= "0"
        end
      end

      class PBXCopyFilesBuildPhase < PBXBuildPhase
        attributes :dstPath, :dstSubfolderSpec

        def initialize(*)
          super
          self.dstSubfolderSpec ||= "16"
        end
      end

      class PBXSourcesBuildPhase < PBXBuildPhase;     end
      class PBXFrameworksBuildPhase < PBXBuildPhase;  end
      class PBXShellScriptBuildPhase < PBXBuildPhase
        attribute :shellScript
      end

    end
  end
end
