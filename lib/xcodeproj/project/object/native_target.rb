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

        # @return [ObjectList<PBXTargetDependency>] the targets necessary to
        #         build this target.
        #
        has_many :dependencies, PBXTargetDependency


        public

        # @!group Helpers
        #--------------------------------------#

        # @return [String] the SDK that the target should use.
        #
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

        # @return [String] the version of the SDK.
        #
        def sdk_version
          sdk.scan(/[0-9.]+/).first
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

        # Adds a new build configuration to the target and populates its with
        # default settings according to the provided type.
        #
        # @note   If a build configuration with the given name is already
        #         present no new build configuration is added.
        #
        # @param  [String] name
        #         The name of the build configuration.
        #
        # @param  [Symbol] type
        #         The type of the build configuration used to populate the build
        #         settings, must be :debug or :release.
        #
        def add_build_configuration(name, type, skip_existing_names = true)
          unless build_configuration_list[name]
            build_configuration = project.new(XCBuildConfiguration)
            build_configuration.name = name
            build_configuration.build_settings = ProjectHelper.common_build_settings(type, platform_name, deployment_target, product_type)
            build_configuration_list.build_configurations << build_configuration
            build_configuration
          end
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

        # Adds a dependency on the given target.
        #
        # @param  [AbstractTarget] target
        #         the target which should be added to the dependencies list of
        #         the receiver.
        #
        # @return [void]
        #
        def add_dependency(target)
          unless dependencies.map(&:target).include?(target)
            container_proxy = project.new(Xcodeproj::Project::PBXContainerItemProxy)
            container_proxy.container_portal = project.root_object.uuid
            container_proxy.proxy_type = '1'
            container_proxy.remote_global_id_string = target.uuid
            container_proxy.remote_info = target.name

            dependency = project.new(Xcodeproj::Project::PBXTargetDependency)
            dependency.target = target
            dependency.target_proxy = container_proxy

            dependencies << dependency
          end
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


        public

        # @!group System frameworks
        #--------------------------------------#

        # Adds a file reference for one or more system framework to the project
        # if needed and adds them to the Frameworks build phases.
        #
        # @param  [Array<String>, String] name
        #         The name or the list of the names of the framework.
        #
        # @return [void]
        #
        def add_system_framework(names)
          Array(names).each do |name|
            path = "System/Library/Frameworks/#{name}.framework"
            unless ref = project.frameworks_group.find_file_by_path(path)
              ref = project.frameworks_group.new_file(path, :sdk_root)
            end
            frameworks_build_phase.add_file_reference(ref, true)
            ref
          end
        end
        alias :add_system_frameworks :add_system_framework

        # Adds a file reference for one or more system libraries to the project
        # if needed and adds them to the Frameworks build phases.
        #
        # @param  [Array<String>, String] name
        #         The name or the list of the names of the libraries.
        #
        # @return [void]
        #
        def add_system_library(names)
          Array(names).each do |name|
            path = "usr/lib/lib#{name}.dylib"
            unless ref = project.frameworks_group.files.find { |ref| ref.path == path }
              ref = project.frameworks_group.new_file(path, :sdk_root)
            end
            frameworks_build_phase.add_file_reference(ref, true)
            ref
          end
        end
        alias :add_system_libraries :add_system_library

        public

        # @!group AbstractObject Hooks
        #--------------------------------------#

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
        attribute :product_type, String

        # @return [PBXFileReference] the reference to the product file.
        #
        has_one :product_reference, PBXFileReference

        # @return [String] the install path of the product.
        #
        attribute :product_install_path, String

        # @return [ObjectList<AbstractBuildPhase>] the build phases of the
        #         target.
        #
        # @note   Apparently only PBXCopyFilesBuildPhase and
        #         PBXShellScriptBuildPhase can appear multiple times in a
        #         target.
        #
        has_many :build_phases, AbstractBuildPhase


        public

        # @!group Helpers
        #--------------------------------------#

        # @return [Symbol] The type of the target expressed as a symbol.
        #
        def symbol_type
          pair = Constants::PRODUCT_TYPE_UTI.find { |key, value| value == product_type }
          pair.first
        end

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

        # Adds resource files to the resources build phase of the target.
        #
        # @param  [Array<PBXFileReference>] resource_file_references
        #         the files references of the resources to the target.
        #
        # @return [void]
        #
        def add_resources(resource_file_references)
          resource_file_references.each do |file|
            build_file = project.new(PBXBuildFile)
            build_file.file_ref = file
            resources_build_phase.files << build_file
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


        public

        # @!group AbstractObject Hooks
        #--------------------------------------#

        # Sorts the to many attributes of the object according to the display
        # name.
        #
        # Build phases are not sorted as they order is relevant.
        #
        def sort(options = nil)
          attributes_to_sort = to_many_attributes.reject { |attr| attr.name == :build_phases }
          attributes_to_sort.each do |attrb|
            list = attrb.get_value(self)
            list.sort! do |x, y|
              x.display_name <=> y.display_name
            end
          end
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
