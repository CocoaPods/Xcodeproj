module Xcodeproj
  class Project
    module Object

      # Represents a target.
      #
      class PBXNativeTarget < AbstractObject

        # @return [String] The name of the Target.
        #
        attribute :name, String

        # @return [XCConfigurationList] the list of the build configurations of
        #   the target. This list commonly include two configurations `Debug`
        #   and `Release`.
        #
        has_one :build_configuration_list, XCConfigurationList

        # @return [PBXBuildRule] the build phases of the target.
        #
        # @note Apparently only PBXCopyFilesBuildPhase and
        #   PBXShellScriptBuildPhase can appear multiple times in a target.
        #
        has_many :build_phases, AbstractBuildPhase

        # @return [PBXBuildRule] the build rules of this target.
        #
        has_many :build_rules, PBXBuildRule

        # @return [PBXNativeTarget] the targets necessary to build this target.
        #
        has_many :dependencies, PBXTargetDependency

        # @return [String] the name of the build product.
        #
        attribute :product_name, String

        # @return [String] the build product type identifier.
        #
        attribute :product_type, String, 'com.apple.product-type.library.static'

        # @return [PBXFileReference] the reference to the product file.
        #
        has_one :product_reference, PBXFileReference

        ## CONVENIENCE METHODS #################################################

        # @!group Convenience methods

        # @return [ObjectList<XCBuildConfiguration>] the build
        #   configurations of the target.
        #
        def build_configurations
          build_configuration_list.build_configurations
        end

        # @return [Hash] the build settings of the build configuration with the
        #   given name.
        #
        # @param [String] build_configuration_name
        #   the name of a build configuration.
        #
        def build_settings(build_configuration_name)
          build_configuration_list.build_settings(build_configuration_name)
        end

        # Adds source files to the target.
        #
        # @param [Array<PBXFileReference>] file_references
        #   The files references of the source files that should be added to
        #   the target.
        #
        # @param [Hash{String=>String}] compiler_flags
        #   The compiler flags for the source files.
        #
        # @return [void]
        #
        def add_file_references(file_references, compiler_flags = {})
          file_references.each do |file|
            build_file = project.new(PBXBuildFile)
            build_file.file_ref = file

            extension = File.extname(file.path)
            header_extensions = %w| .h .hpp |
            if (header_extensions.include?(extension))
              build_file.settings = { 'ATTRIBUTES' => ["Public"] }
              phase = headers_build_phase
              phase.files << build_file
            else
              build_file.settings = { 'COMPILER_FLAGS' => compiler_flags } if compiler_flags && !compiler_flags.empty?
              source_build_phase.files << build_file
            end
          end
        end


        # @!group Accessing build phases

        # Finds or creates the headers build phase of the target.
        #
        # @note A target should have only one headers build phase.
        #
        # @return [PBXHeadersBuildPhase] the headers build phase.
        #
        def headers_build_phase
          unless @headers_build_phase
            headers_build_phase = build_phases.find { |bp| bp.class == PBXHeadersBuildPhase }
            unless headers_build_phase
              # Working around a bug in Xcode 4.2 betas, remove this once the
              # Xcode bug is fixed:
              # https://github.com/alloy/cocoapods/issues/13
              # phase = copy_header_phase || headers_build_phases.first
              headers_build_phase = project.new(PBXHeadersBuildPhase)
              build_phases << headers_build_phase
            end
            @headers_build_phase = headers_build_phase
          end
          @headers_build_phase
        end

        # Finds or creates the source build phase of the target.
        #
        # @note A target should have only one source build phase.
        #
        # @return [PBXSourcesBuildPhase] the source build phase.
        #
        def source_build_phase
          unless @source_build_phase
            source_build_phase = build_phases.find { |bp| bp.class == PBXSourcesBuildPhase }
            unless source_build_phase
              source_build_phase = project.new(PBXSourcesBuildPhase)
              build_phases << source_build_phase
            end
            @source_build_phase = source_build_phase
          end
          @source_build_phase
        end

        # Finds or creates the frameworks build phase of the target.
        #
        # @note A target should have only one frameworks build phase.
        #
        # @return [PBXFrameworksBuildPhase] the frameworks build phase.
        #
        def frameworks_build_phase
          bp = build_phases.find { |bp| bp.class == PBXFrameworksBuildPhase }
          unless bp
            bp = project.new(PBXFrameworksBuildPhase)
            build_phases << bp
          end
          bp
        end

        # Finds or creates the resources build phase of the target.
        #
        # @note A target should have only one resources build phase.
        #
        # @return [PBXResourcesBuildPhase] the resources build phase.
        #
        def resources_build_phase
          bp = build_phases.find { |bp| bp.class == PBXResourcesBuildPhase }
          unless bp
            bp = project.new(PBXResourcesBuildPhase)
            build_phases << bp
          end
          bp
        end

        # @return [Array<PBXCopyFilesBuildPhase>]
        #   the copy files build phases of the target.
        #
        def copy_files_build_phases
          build_phases.find { |bp| bp.class == PBXCopyFilesBuildPhase }
        end

        # @return [Array<PBXShellScriptBuildPhase>]
        #   the copy files build phases of the target.
        #
        def shell_script_build_phases
          build_phases.find { |bp| bp.class == PBXShellScriptBuildPhase }
        end


        # @!group Creating build phases

        # Creates a new copy files build phase.
        #
        # @param [String] name
        #   an optional name for the pahse.
        #
        # @return [PBXCopyFilesBuildPhase] the new phase.
        #
        def new_copy_files_build_phase(name = nil)
          phase = project.new(PBXCopyFilesBuildPhase)
          build_phases << phase
          phase
        end

        # Creates a new shell script build phase.
        #
        # @param (see #new_copy_files_build_phase)
        #
        # @return [PBXShellScriptBuildPhase] the new phase.
        #
        def new_shell_script_build_phase(name = nil)
          phase = project.new(PBXShellScriptBuildPhase)
          build_phases << phase
          phase
        end
      end
    end
  end
end
