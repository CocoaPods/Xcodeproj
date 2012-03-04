module Xcodeproj
  class Project
    module Object

      class PBXNativeTarget < PBXObject
        STATIC_LIBRARY = 'com.apple.product-type.library.static'

        # [String] the name of the build product
        attribute :product_name

        # [String] the build product type identifier
        attribute :product_type

        has_many :build_phases
        has_many :dependencies # TODO :class => ?
        has_many :build_rules # TODO :class => ?
        has_one :build_configuration_list
        has_one :product, :uuid => :product_reference

        def self.new_static_library(project, productName)
          # TODO should probably switch the uuid and attributes argument
          target = new(project, nil, 'productType' => STATIC_LIBRARY, 'productName' => productName)
          target.product = project.files.new_static_library(productName)
          products = project.groups.find { |g| g.name == 'Products' }
          products ||= project.groups.new({ 'name' => 'Products'})
          products.children << target.product
          target.build_phases.add(PBXSourcesBuildPhase)

          build_phase = target.build_phases.add(PBXFrameworksBuildPhase)
          frameworks = project.groups.find { |g| g.name == 'Frameworks' }
          frameworks ||= project.groups.new({ 'name' => 'Frameworks'})
          frameworks.files.each do |framework|
            build_phase.files << framework.build_files.new
          end

          target.build_phases.add(PBXCopyFilesBuildPhase, 'dstPath' => '$(PRODUCT_NAME)')
          target
        end

        # You need to specify a product. For a static library you can use
        # PBXFileReference.new_static_library.
        def initialize(project, *)
          super
          self.name ||= product_name
          self.build_rule_references  ||= []
          self.dependency_references  ||= []
          self.build_phase_references ||= []

          unless build_configuration_list
            self.build_configuration_list = project.objects.add(XCConfigurationList)
            # TODO or should this happen in buildConfigurationList?
            build_configuration_list.build_configurations.new('name' => 'Debug')
            build_configuration_list.build_configurations.new('name' => 'Release')
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
          build_phases.select_by_class(PBXSourcesBuildPhase)
        end

        def copy_files_build_phases
          build_phases.select_by_class(PBXCopyFilesBuildPhase)
        end

        def frameworks_build_phases
          build_phases.select_by_class(PBXFrameworksBuildPhase)
        end
        
        def shell_script_build_phases
          build_phases.select_by_class(PBXShellScriptBuildPhase)
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
