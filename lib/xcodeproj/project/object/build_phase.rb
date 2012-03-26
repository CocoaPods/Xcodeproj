module Xcodeproj
  class Project
    module Object

      class PBXBuildFile < AbstractPBXObject
        # [Hash] the list of build settings for this file
        attribute :settings

        has_one :file, :uuid => :file_ref
      end

      class PBXBuildPhase < AbstractPBXObject
        # TODO rename this to buildFiles and add a files :through => :buildFiles shortcut
        has_many :files, :class => PBXBuildFile

        # [String] some kind of magic number which seems to always be '2147483647'
        attribute :build_action_mask

        # [String] wether or not this should only be processed before deployment
        #          (I guess). This cane be either '0', or '1'
        attribute :run_only_for_deployment_postprocessing

        def initialize(*)
          super
          self.file_references ||= []
          # These are always the same, no idea what they are.
          self.build_action_mask ||= "2147483647"
          self.run_only_for_deployment_postprocessing ||= "0"
        end
      end

      class PBXCopyFilesBuildPhase < PBXBuildPhase
        # [String] the path where this file should be copied to
        attribute :dst_path

        # [String] a magic number which always seems to be "16"
        attribute :dst_subfolder_spec

        def initialize(*)
          super
          self.dst_path ||= '$(PRODUCT_NAME)'
          self.dst_subfolder_spec ||= "16"
        end
      end

      class PBXSourcesBuildPhase < PBXBuildPhase;     end
      class PBXFrameworksBuildPhase < PBXBuildPhase;  end

      # @todo Should `files`, `input_paths`, and `output_paths` be has_many
      #       associations with file references?
      class PBXShellScriptBuildPhase < PBXBuildPhase
        attribute :name

        attribute :files
        attribute :input_paths
        attribute :output_paths

        # [String] The path to the script interpreter. Defaults to `/bin/sh`.
        attribute :shell_path

        # [String] The actual script to perform.
        attribute :shell_script

        def initialize(*)
          super
          self.files        ||= []
          self.input_paths  ||= []
          self.output_paths ||= []

          self.shell_path   ||= '/bin/sh'
          self.shell_script ||= ''
        end
      end

    end
  end
end
