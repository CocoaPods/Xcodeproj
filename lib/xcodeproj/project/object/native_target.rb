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

        # Gets the value for the given build setting in all the build
        # configurations or the value inheriting the value from the project
        # ones if needed.
        #
        # @param [String] key
        #        the key of the build setting.
        #
        # @return [Hash{String => String}] The value of the build setting
        #         grouped by the name of the build configuration.
        #
        # TODO:   Full support for this would require to take into account
        #         any associated xcconfig and the default values for the
        #         platform.
        #
        def resolved_build_setting(key)
          target_settings = build_configuration_list.get_setting(key)
          project_settings = project.build_configuration_list.get_setting(key)
          target_settings.merge(project_settings) do |key, target_val, proj_val|
            target_val || proj_val
          end
        end

        # Gets the value for the given build setting, properly inherited if
        # need, if shared across the build configurations.
        #
        # @param [String] key
        #        the key of the build setting.
        #
        # @raise  If the build setting has multiple values.
        #
        # @note   As it is common not to have a setting with no value for
        #         custom build configurations nil keys are not considered to
        #         determine if the setting is unique. This is an heuristic
        #         which might not closely match Xcode behaviour.
        #
        # @return [String] The value of the build setting.
        #
        def common_resolved_build_setting(key)
          values = resolved_build_setting(key).values.compact.uniq
          if values.count <= 1
            values.first
          else
            raise "[Xcodeproj] Consistency issue: build setting `#{key}` has multiple values: `#{resolved_build_setting(key)}`"
          end
        end

        # @return [String] the SDK that the target should use.
        #
        def sdk
          common_resolved_build_setting('SDKROOT')
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
          if sdk
            sdk.scan(/[0-9.]+/).first
          end
        end

        # @return [String] the deployment target of the target according to its
        #         platform.
        #
        def deployment_target
          if platform_name == :ios
            common_resolved_build_setting('IPHONEOS_DEPLOYMENT_TARGET')
          else
            common_resolved_build_setting('MACOSX_DEPLOYMENT_TARGET')
          end
        end

        # @return [ObjectList<XCBuildConfiguration>] the build
        #         configurations of the target.
        #
        def build_configurations
          build_configuration_list.build_configurations
        end

        # Adds a new build configuration to the target and populates its with
        # default settings according to the provided type if one doesn't
        # exists.
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
        # @return [XCBuildConfiguration] the created build configuration or the
        #         existing one with the same name.
        #
        def add_build_configuration(name, type)
          if existing = build_configuration_list[name]
            existing
          else
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
        #         the receiver. The target may be a target of this target's
        #         project or of a subproject of this project. Note that the
        #         subproject must already be added to this target's project.
        #
        # @return [void]
        #
        def add_dependency(target)
          unless dependencies.map(&:target).include?(target)
            container_proxy = project.new(Xcodeproj::Project::PBXContainerItemProxy)
            if target.project == project
              container_proxy.container_portal = project.root_object.uuid
            else
              subproject_reference = project.reference_for_path(target.project.path)
              raise ArgumentError, "add_dependency got target that belongs to a project is not this project and is not a subproject of this project" unless subproject_reference
              container_proxy.container_portal = subproject_reference.uuid
            end
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
        # @note   Xcode behaviour is following: if the target has the same SDK
        #         of the project it adds the reference relative to the SDK root
        #         otherwise the reference is added relative to the Developer
        #         directory. This can create confusion or duplication of the
        #         references of frameworks linked by iOS and OS X targets. For
        #         this reason the new Xcodeproj behaviour is to add the
        #         frameworks in a subgroup according to the platform.
        #
        # @return [void]
        #
        def add_system_framework(names)
          Array(names).each do |name|

            case platform_name
            when :ios
              group = project.frameworks_group['iOS'] || project.frameworks_group.new_group('iOS')
              path_sdk_name = 'iPhoneOS'
              path_sdk_version = sdk_version || Constants::LAST_KNOWN_IOS_SDK
            when :osx
              group = project.frameworks_group['OS X'] || project.frameworks_group.new_group('OS X')
              path_sdk_name = 'MacOSX'
              path_sdk_version = sdk_version || Constants::LAST_KNOWN_OSX_SDK
            else
              raise "Unknown platform for target"
            end

            path = "Platforms/#{path_sdk_name}.platform/Developer/SDKs/#{path_sdk_name}#{path_sdk_version}.sdk/System/Library/Frameworks/#{name}.framework"
            unless ref = group.find_file_by_path(path)
              ref = group.new_file(path, :developer_dir)
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
