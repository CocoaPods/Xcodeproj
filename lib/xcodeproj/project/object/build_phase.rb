module Xcodeproj
  class Project
    module Object

      # @abstract
      #
      # This class is abstract and it doesn't appear in the project document.
      #
      class AbstractBuildPhase < AbstractObject


        # @return [ObjectList<PBXBuildFile>] the files processed by this build
        #   configuration.
        #
        has_many :files, PBXBuildFile

        # @return [String] some kind of magic number which usually is
        #   '2147483647' (can be also `8` and `12` in PBXCopyFilesBuildPhase,
        #   one of the masks is run_only_for_deployment_postprocessing).
        #
        attribute :build_action_mask, String, '2147483647'

        # @return [String] whether or not this should only be processed before
        #   deployment. Can be either '0', or '1'.
        #
        # This option is exposed in Xcode in the UI of PBXCopyFilesBuildPhase as
        # `Copy only when installing` or in PBXShellScriptBuildPhase as `Run
        # script only when installing`.
        #
        attribute :run_only_for_deployment_postprocessing, String, '0'

      end

      ### Phases that can appear only once in a target. ########################

      # The phase responsible of copying headers (aka `Copy Headers`).
      #
      class PBXHeadersBuildPhase < AbstractBuildPhase

      end

      # The phase responsible of compiling the files (aka `Compile Sources`).
      #
      class PBXSourcesBuildPhase < AbstractBuildPhase

      end

      # The phase responsible on linking with frameworks (aka `Link Binary With
      # Libraries`).
      #
      class PBXFrameworksBuildPhase < AbstractBuildPhase

      end

      # The resources build phase apparently is a specialized copy build phase
      # for resources (aka `Copy Bundle Resources`). It is unclear if this is
      # the only one capable of optimize PNG.
      #
      class PBXResourcesBuildPhase < AbstractBuildPhase

      end

      ### Phases that can appear multiple times in a target. ###################

      # Phase that copies the files to the bundle of the target (aka `Copy
      # Files`).
      #
      class PBXCopyFilesBuildPhase < AbstractBuildPhase

        # @return [String] the name of the build phase.
        #
        attribute :name, String

        # @return [String] the subpath of `dst_subfolder_spec` where this file
        #   should be copied to.
        #
        #   Can accept environment variables like `$(PRODUCT_NAME)`.
        #
        attribute :dst_path, String, ''

        # @return [String] the path (destination) where the files should be
        #   copied to.
        #
        attribute :dst_subfolder_spec, String, Constants::COPY_FILES_BUILD_PHASE_DESTINATIONS[:resources]

      end

      # A phase responsible of running a shell script (aka `Run Script`).
      #
      class PBXShellScriptBuildPhase < AbstractBuildPhase

        # @return [String] the name of the build phase.
        #
        attribute :name, String

        # @return [Array<String>] an array of the paths to pass to the script.
        #
        # @example
        #   "$(SRCROOT)/myfile"
        #
        attribute :input_paths, Array, []

        # @return [Array<String>] an array of output paths of the script.
        #
        # @example
        #   "$(DERIVED_FILE_DIR)/myfile"
        #
        attribute :output_paths, Array, []

        # @return [String] the path to the script interpreter.
        #
        # Defaults to `/bin/sh`.
        #
        attribute :shell_path, String, '/bin/sh'

        # @return [String] the actual script to perform.
        #
        # Defaults to the empty string.
        #
        attribute :shell_script, String, ''

      end

      class AbstractBuildPhase < AbstractObject

        ## CONVENIENCE METHODS #################################################

        # @!group Convenience methods

        # @return [Array<PBXFileReference>] the list of all the files
        #   referenced by this build phase.
        #
        def files_references
          files.map { |bf| bf.file_ref }.uniq
        end

        # Adds a new build file, initialized with the given file reference, to
        # the phase.
        #
        # @param [PBXFileReference] file
        #   the file reference that should be added to the build phase.
        #
        # @return [PBXBuildFile] the build file generated.
        #
        def add_file_reference(file)
          build_file = project.new(PBXBuildFile)
          build_file.file_ref = file
          files << build_file
          build_file
        end

        # Removes a file reference from the build phase
        #
        # @param [PBXObject] file the file to remove
        def remove_file_reference(file)
          build_file = files.find { |bf| bf.file_ref == file }
          build_file.file_ref = nil
          build_file.remove_from_project
        end

        def remove_build_file(build_file)
          build_file.file_ref = nil
          build_file.remove_from_project
        end
      end
    end
  end
end
