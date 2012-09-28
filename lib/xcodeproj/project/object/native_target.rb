module Xcodeproj
  class Project
    module Object

      class PBXNativeTarget < AbstractPBXObject
        STATIC_LIBRARY = 'com.apple.product-type.library.static'

        # [String] the name of the build product
        attribute :product_name

        # [String] the build product type identifier
        attribute :product_type

        has_many :build_phases
        has_many :dependencies # TODO :class => ?
        has_many :build_rules # TODO :class => ?
        has_one :build_configuration_list, :class => XCConfigurationList
        has_one :product, :uuid => :product_reference

        def self.new_static_library(project, platform, name)
          project.add_system_framework(platform == :ios ? 'Foundation' : 'Cocoa')

          target = new(project, nil, 'productType' => STATIC_LIBRARY, 'productName' => name)
          target.product.path = "lib#{name}.a"

          target.build_configurations.each do |config|
            config.build_settings.merge!(XCBuildConfiguration::COMMON_BUILD_SETTINGS[platform])

            # E.g. [:ios, :release]
            extra_settings_key = [platform, config.name.downcase.to_sym]
            if extra_settings = XCBuildConfiguration::COMMON_BUILD_SETTINGS[extra_settings_key]
              config.build_settings.merge!(extra_settings)
            end
          end

          target
        end

        # You need to specify a product. For a static library you can use
        # PBXFileReference.new_static_library.
        def initialize(project, *)
          super
          self.name ||= product_name
          self.build_rule_references  ||= []
          self.dependency_references  ||= []

          unless build_phase_references
            self.build_phase_references = []

            source_build_phases.new
            copy_files_build_phases.new
            #shell_script_build_phases.new

            phase = frameworks_build_phases.new
            if frameworks_group = @project.groups.where(:name => 'Frameworks')
              frameworks_group.files.each { |framework| phase << framework }
            end
          end

          unless build_configuration_list
            self.build_configuration_list = project.objects.add(XCConfigurationList, {
              'defaultConfigurationIsVisible' => '0',
              'defaultConfigurationName' => 'Release',
            })
            # TODO or should this happen in buildConfigurationList?
            build_configuration_list.build_configurations.new_debug
            build_configuration_list.build_configurations.new_release
          end

          unless product
            self.product = @project.files.new_static_library(product_name)
          end
        end

        alias_method :_product=, :product=
        def product=(product)
          self._product = product
          @project.products << product
        end

        def build_configurations
          build_configuration_list.build_configurations
        end

        def build_settings(build_configuration_name)
          build_configuration_list.build_settings(build_configuration_name)
        end

        def source_build_phases
          build_phases.list_by_class(PBXSourcesBuildPhase)
        end

        def copy_files_build_phases
          build_phases.list_by_class(PBXCopyFilesBuildPhase)
        end

        def frameworks_build_phases
          build_phases.list_by_class(PBXFrameworksBuildPhase)
        end

        def shell_script_build_phases
          build_phases.list_by_class(PBXShellScriptBuildPhase)
        end

        # Adds source files to the target.
        #
        # @note
        #   It finds an existing file reference or creates a new one.
        #
        # @param source_file_descriptions [Array<SourceFileDescription>] The
        #   description of the source files to add.
        #
        # @return [Array<PBXFileReference>]
        #
        def add_source_files(source_file_descriptions)
          # Cache the files for performance.
          files = @project.files.to_a
          new_files = []
          source_file_descriptions.each do |source_file_description|
            path              = source_file_description.path
            copy_header_phase = source_file_description.copy_header_phase
            compiler_flags    = source_file_description.compiler_flags

            file = (files + new_files).find { |file| file.path == path.to_s } || @project.files.new('path' => path.to_s)
            build_file = file.build_files.new
            if (path.extname == '.h' || path.extname == '.hpp')
              build_file.settings = { 'ATTRIBUTES' => ["Public"] }
              # Working around a bug in Xcode 4.2 betas, remove this once the Xcode bug is fixed:
              # https://github.com/alloy/cocoapods/issues/13
              #phase = copy_header_phase || headers_build_phases.first
              phase = copy_header_phase || copy_files_build_phases.first
              phase.build_files << build_file
            else
              build_file.settings = { 'COMPILER_FLAGS' => compiler_flags } if compiler_flags && !compiler_flags.empty?
              source_build_phases.first.build_files << build_file
            end
            new_files << file
          end
          new_files
        end

        # Struct representing the description needed to add a source file to
        # the target.
        #
        # @!attribute path
        #   @return [Pathname] The path of the file.
        #
        # @!attribute compiler_flags
        #   @return [String] Any compiler flag.
        #
        # @!attribute copy_header_phase
        #   @return [PBXCopyFilesBuildPhase].
        #
        SourceFileDescription = Struct.new(:path, :compiler_flags, :copy_header_phase)
      end
    end
  end
end
