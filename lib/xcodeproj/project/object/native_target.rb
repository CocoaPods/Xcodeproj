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
        has_one :product

        # @todo a lot of this should move to the normal initialize method, like creating build phases.
        def self.new_static_library(project, productName)
          # TODO should probably switch the uuid and attributes argument
          target = new(project, nil, 'productType' => STATIC_LIBRARY, 'productName' => productName)
          target.product.path = "lib#{productName}.a"
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
            shell_script_build_phases.new

            phase = frameworks_build_phases.new
            if frameworks_group = @project.groups.where(:name => 'Frameworks')
              frameworks_group.files.each do |framework|
                phase.files << framework.build_files.new
              end
            end
          end

          unless build_configuration_list
            self.build_configuration_list = project.objects.add(XCConfigurationList)
            # TODO or should this happen in buildConfigurationList?
            build_configuration_list.build_configurations.new('name' => 'Debug')
            build_configuration_list.build_configurations.new('name' => 'Release')
          end

          # The path still has to be set by the user!
          unless product
            self.product = @project.files.new("includeInIndex" => "0", "sourceTree" => "BUILT_PRODUCTS_DIR")
            @project.products << product
          end
        end

        alias_method :_product=, :product=
        def product=(product)
          self._product = product
          @project.products_group << product
        end

        def build_configurations
          build_configuration_list.build_configurations
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

        # Finds an existing file reference or creates a new one.
        def add_source_file(path, copy_header_phase = nil, compiler_flags = nil)
          file = @project.files.find { |file| file.path == path.to_s } || @project.files.new('path' => path.to_s)
          build_file = file.build_files.new
          if path.extname == '.h'
            build_file.settings = { 'ATTRIBUTES' => ["Public"] }
            # Working around a bug in Xcode 4.2 betas, remove this once the Xcode bug is fixed:
            # https://github.com/alloy/cocoapods/issues/13
            #phase = copy_header_phase || headers_build_phases.first
            phase = copy_header_phase || copy_files_build_phases.first
            phase.files << build_file
          else
            build_file.settings = { 'COMPILER_FLAGS' => compiler_flags } if compiler_flags
            source_build_phases.first.files << build_file
          end
          file
        end
      end

    end
  end
end
