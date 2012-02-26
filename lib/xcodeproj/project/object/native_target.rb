module Xcodeproj
  class Project
    module Object

      class PBXNativeTarget < PBXObject
        STATIC_LIBRARY = 'com.apple.product-type.library.static'

        attributes :productName, :productType

        has_many :buildPhases
        has_many :dependencies # TODO :class => ?
        has_many :buildRules # TODO :class => ?
        has_one :buildConfigurationList
        has_one :product, :uuid => :productReference

        def self.new_static_library(project, productName)
          # TODO should probably switch the uuid and attributes argument
          target = new(project, nil, 'productType' => STATIC_LIBRARY, 'productName' => productName)
          target.product = project.files.new_static_library(productName)
          products = project.groups.find { |g| g.name == 'Products' }
          products ||= project.groups.new({ 'name' => 'Products'})
          products.children << target.product
          target.buildPhases.add(PBXSourcesBuildPhase)

          buildPhase = target.buildPhases.add(PBXFrameworksBuildPhase)
          frameworks = project.groups.find { |g| g.name == 'Frameworks' }
          frameworks ||= project.groups.new({ 'name' => 'Frameworks'})
          frameworks.files.each do |framework|
            buildPhase.files << framework.buildFiles.new
          end

          target.buildPhases.add(PBXCopyFilesBuildPhase, 'dstPath' => '$(PRODUCT_NAME)')
          target
        end

        # You need to specify a product. For a static library you can use
        # PBXFileReference.new_static_library.
        def initialize(project, *)
          super
          self.name ||= productName
          self.buildRuleReferences  ||= []
          self.dependencyReferences ||= []
          self.buildPhaseReferences ||= []

          unless buildConfigurationList
            self.buildConfigurationList = project.objects.add(XCConfigurationList)
            # TODO or should this happen in buildConfigurationList?
            buildConfigurationList.buildConfigurations.new('name' => 'Debug')
            buildConfigurationList.buildConfigurations.new('name' => 'Release')
          end
        end

        alias_method :_product=, :product=
        def product=(product)
          self._product = product
          product.group = @project.products
        end

        def buildConfigurations
          buildConfigurationList.buildConfigurations
        end

        def source_build_phases
          buildPhases.select_by_class(PBXSourcesBuildPhase)
        end

        def copy_files_build_phases
          buildPhases.select_by_class(PBXCopyFilesBuildPhase)
        end

        def frameworks_build_phases
          buildPhases.select_by_class(PBXFrameworksBuildPhase)
        end
        
        def shell_script_build_phases
          buildPhases.select_by_class(PBXShellScriptBuildPhase)
        end

        # Finds an existing file reference or creates a new one.
        def add_source_file(path, copy_header_phase = nil, compiler_flags = nil)
          file = @project.files.find { |file| file.path == path.to_s } || @project.files.new('path' => path.to_s)
          buildFile = file.buildFiles.new
          if path.extname == '.h'
            buildFile.settings = { 'ATTRIBUTES' => ["Public"] }
            # Working around a bug in Xcode 4.2 betas, remove this once the Xcode bug is fixed:
            # https://github.com/alloy/cocoapods/issues/13
            #phase = copy_header_phase || headers_build_phases.first
            phase = copy_header_phase || copy_files_build_phases.first
            phase.files << buildFile
          else
            buildFile.settings = { 'COMPILER_FLAGS' => compiler_flags } if compiler_flags
            source_build_phases.first.files << buildFile
          end
          file
        end
      end

    end
  end
end
