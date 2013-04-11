module Xcodeproj
  class Project
    module Object

      class AbstractTarget < AbstractObject

        # @!group Attributes

        # @return [String] The name of the Target.
        #
        attribute :name, String

        # @return [String] the name of the build product.
        #
        attribute :product_name, String

        # @return [String] Comments associated with this target.
        #
        #   This is apparently no longer used by Xcode.
        #
        attribute :comments, String

        # @return [XCConfigurationList] the list of the build configurations of
        #         the target. This list commonly include two configurations
        #         `Debug` and `Release`.
        #
        has_one :build_configuration_list, XCConfigurationList

        # @return [PBXNativeTarget] the targets necessary to build this target.
        #
        has_many :dependencies, PBXTargetDependency

        #--------------------------------------#

        public

        # @!group Helpers

        def sdk
          build_configurations.first.build_settings['SDKROOT'] \
            || project.build_configurations.first.build_settings['SDKROOT']
        end

        # @return [Symbol] the name of the platform of the target.
        #
        def platform_name
          if    sdk.include? 'iphoneos' then :ios
          elsif sdk.include? 'macosx'   then :osx
          end
        end

        # @return [String] the deployment target of the target according to its
        #         platform.
        #
        def deployment_target
          if platform_name == :ios
            build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] ||
              project.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
          else
            build_configurations.first.build_settings['MACOSX_DEPLOYMENT_TARGET'] ||
              project.build_configurations.first.build_settings['MACOSX_DEPLOYMENT_TARGET']
          end
        end

        # @return [ObjectList<XCBuildConfiguration>] the build
        #         configurations of the target.
        #
        def build_configurations
          build_configuration_list.build_configurations
        end

        # @param  [String] build_configuration_name
        #         the name of a build configuration.
        #
        # @return [Hash] the build settings of the build configuration with the
        #         given name.
        #
        #
        def build_settings(build_configuration_name)
          build_configuration_list.build_settings(build_configuration_name)
        end

        # @!group Build Phases Helpers

        # @return [PBXFrameworksBuildPhase]
        #         the copy files build phases of the target.
        #
        def frameworks_build_phases
          build_phases.find { |bp| bp.class == PBXFrameworksBuildPhase }
        end

        # @return [Array<PBXCopyFilesBuildPhase>]
        #         the copy files build phases of the target.
        #
        def copy_files_build_phases
          build_phases.select { |bp| bp.class == PBXCopyFilesBuildPhase }
        end

        # @return [Array<PBXShellScriptBuildPhase>]
        #         the copy files build phases of the target.
        #
        def shell_script_build_phases
          build_phases.select { |bp| bp.class == PBXShellScriptBuildPhase }
        end

        # Creates a new copy files build phase.
        #
        # @param  [String] name
        #         an optional name for the phase.
        #
        # @return [PBXCopyFilesBuildPhase] the new phase.
        #
        def new_copy_files_build_phase(name = nil)
          phase = project.new(PBXCopyFilesBuildPhase)
          phase.name = name
          build_phases << phase
          phase
        end

        # Creates a new shell script build phase.
        #
        # @param  (see #new_copy_files_build_phase)
        #
        # @return [PBXShellScriptBuildPhase] the new phase.
        #
        def new_shell_script_build_phase(name = nil)
          phase = project.new(PBXShellScriptBuildPhase)
          phase.name = name
          build_phases << phase
          phase
        end

        #--------------------------------------#

        public

        # @!group AbstractObject Hooks

        # @return [Hash{String => Hash}] A hash suitable to display the object
        #         to the user.
        #
        def pretty_print
          {
            display_name => {
              'Build Phases' => build_phases.map(&:pretty_print),
              'Build Configurations' => build_configurations.map(&:pretty_print)
            }
          }
        end

      end

      #-----------------------------------------------------------------------#

      # Represents a target handled by Xcode.
      #
      class PBXNativeTarget < AbstractTarget

        # @!group Attributes

        # @return [PBXBuildRule] the build rules of this target.
        #
        has_many :build_rules, PBXBuildRule

        # @return [String] the build product type identifier.
        #
        attribute :product_type, String, 'com.apple.product-type.library.static'

        # @return [PBXFileReference] the reference to the product file.
        #
        has_one :product_reference, PBXFileReference

        # @return [String] the install path of the product.
        #
        attribute :product_install_path, String

        # @return [PBXBuildRule] the build phases of the target.
        #
        # @note   Apparently only PBXCopyFilesBuildPhase and
        #         PBXShellScriptBuildPhase can appear multiple times in a
        #         target.
        #
        has_many :build_phases, AbstractBuildPhase

        #--------------------------------------#

        public

        # @!group Helpers

        # Adds source files to the target.
        #
        # @param  [Array<PBXFileReference>] file_references
        #         the files references of the source files that should be added
        #         to the target.
        #
        # @param  [Hash{String=>String}] compiler_flags
        #         the compiler flags for the source files.
        #
        # @return [void]
        #
        def add_file_references(file_references, compiler_flags = {})
          file_references.each do |file|
            build_file = project.new(PBXBuildFile)
            build_file.file_ref = file

            extension = File.extname(file.path)
            header_extensions = Constants::HEADER_FILES_EXTENSIONS
            if (header_extensions.include?(extension))
              headers_build_phase.files << build_file
            else
              if compiler_flags && !compiler_flags.empty?
                build_file.settings = { 'COMPILER_FLAGS' => compiler_flags }
              end
              source_build_phase.files << build_file
            end
          end
        end

        # Finds or creates the headers build phase of the target.
        #
        # @note   A target should have only one headers build phase.
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
        # @note   A target should have only one source build phase.
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
        # @note   A target should have only one frameworks build phase.
        #
        # @return [PBXFrameworksBuildPhase] the frameworks build phase.
        #
        def frameworks_build_phase
          phase = build_phases.find { |bp| bp.class == PBXFrameworksBuildPhase }
          unless phase
            phase= project.new(PBXFrameworksBuildPhase)
            build_phases << phase
          end
          phase
        end

        # Finds or creates the resources build phase of the target.
        #
        # @note   A target should have only one resources build phase.
        #
        # @return [PBXResourcesBuildPhase] the resources build phase.
        #
        def resources_build_phase
          phase = build_phases.find { |bp| bp.class == PBXResourcesBuildPhase }
          unless phase
            phase = project.new(PBXResourcesBuildPhase)
            build_phases << phase
          end
          phase
        end

      end

      #-----------------------------------------------------------------------#

      # Represents a target that only consists in a aggregate of targets.
      #
      # @todo Apparently it can't have build rules.
      #
      class PBXAggregateTarget < AbstractTarget

        # @!group Attributes

        # @return [PBXBuildRule] the build phases of the target.
        #
        # @note   Apparently only PBXCopyFilesBuildPhase and
        #         PBXShellScriptBuildPhase can appear multiple times in a
        #         target.
        #
        has_many :build_phases, [ PBXCopyFilesBuildPhase, PBXShellScriptBuildPhase ]

      end

      #-----------------------------------------------------------------------#

      # Represents a legacy target which uses an external build tool.
      #
      # Apparently it can't have any build phase but the attribute can be
      # present.
      #
      class PBXLegacyTarget < AbstractTarget

        # @!group Attributes

        # @return [String] e.g "Dir"
        #
        attribute :build_working_directory, String

        # @return [String] e.g "$(ACTION)"
        #
        attribute :build_arguments_string, String

        # @return [String] e.g "1"
        #
        attribute :pass_build_settings_in_environment, String

        # @return [String] e.g "/usr/bin/make"
        #
        attribute :build_tool_path, String

        # @return [PBXBuildRule] the build phases of the target.
        #
        # @note   Apparently only PBXCopyFilesBuildPhase and
        #         PBXShellScriptBuildPhase can appear multiple times in a
        #         target.
        #
        has_many :build_phases, AbstractBuildPhase

      end

      #-----------------------------------------------------------------------#

    end
  end
end
