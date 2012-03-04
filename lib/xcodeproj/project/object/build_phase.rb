module Xcodeproj
  class Project
    module Object

      class PBXBuildFile < PBXObject
        attributes :settings
        has_one :file, :uuid => :file_ref
      end

      class PBXBuildPhase < PBXObject
        # TODO rename this to buildFiles and add a files :through => :buildFiles shortcut
        has_many :files, :class => PBXBuildFile

        attributes :build_action_mask, :run_only_for_deployment_postprocessing

        def initialize(*)
          super
          self.file_references ||= []
          # These are always the same, no idea what they are.
          self.build_action_mask ||= "2147483647"
          self.run_only_for_deployment_postprocessing ||= "0"
        end
      end

      class PBXCopyFilesBuildPhase < PBXBuildPhase
        attributes :dst_path, :dst_subfolder_spec

        def initialize(*)
          super
          self.dst_subfolder_spec ||= "16"
        end
      end

      class PBXSourcesBuildPhase < PBXBuildPhase;     end
      class PBXFrameworksBuildPhase < PBXBuildPhase;  end
      class PBXShellScriptBuildPhase < PBXBuildPhase
        attribute :shell_script
      end

    end
  end
end
