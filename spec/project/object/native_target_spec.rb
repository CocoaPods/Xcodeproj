require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs

  describe AbstractTarget do
    describe "In general" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
        @sut.name.should == "Pods"
        @sut.product_name.should == "Pods"
      end
    end

    #----------------------------------------#

    describe "AbstractObject Hooks" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the pretty print representation" do
        pretty_print = @sut.pretty_print
        pretty_print['Pods']['Build Phases'].should == [
          { "SourcesBuildPhase" => [] },
          { "FrameworksBuildPhase" => ["Foundation.framework"] }
        ]
        build_configurations = pretty_print['Pods']['Build Configurations']
        build_configurations.map { |bf| bf.keys.first } .should == ["Release", "Debug"]
      end
    end

    #----------------------------------------#

    describe "Helpers" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the SDK specified in its build configuration" do
        @project.build_configurations.first.build_settings['SDKROOT'] = nil
        @sut.sdk.should == 'iphoneos'
      end

      it "returns the SDK of the project if one is not specified in the build configurations" do
        @project.build_configurations.first.build_settings['SDKROOT'] = 'iphoneos'
        @sut.build_configurations.first.build_settings['SDKROOT'] = nil
        @sut.sdk.should == 'iphoneos'
      end

      it "returns the platform name" do
        @project.new_target(:static_library, 'Pods', :ios).platform_name.should == :ios
        @project.new_target(:static_library, 'Pods', :osx).platform_name.should == :osx
      end

      it "returns the deployment target specified in its build configuration" do
        @project.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = nil
        @project.build_configurations.first.build_settings['MACOSX_DEPLOYMENT_TARGET'] = nil
        @project.new_target(:static_library, 'Pods', :ios).deployment_target.should == '4.3'
        @project.new_target(:static_library, 'Pods', :osx).deployment_target.should == '10.7'
      end

      it "returns the deployment target" do
        @project.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '4.3'
        @project.build_configurations.first.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.7'
        mac_target = @project.new_target(:static_library, 'Pods', :ios)
        mac_target.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = nil
        mac_target.deployment_target.should == '4.3'
      end

      it "returns the build configuration" do
        build_configurations = @sut.build_configurations
        build_configurations.map(&:isa).uniq.should == ['XCBuildConfiguration']
        build_configurations.map(&:name).sort.should == ["Debug", "Release"]
      end

      it "returns the build settings of the configuration with the given name" do
        @sut.build_settings('Debug')['PRODUCT_NAME'].should == "$(TARGET_NAME)"
      end
    end

    #----------------------------------------#

    describe "Build phases" do
      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
        @sut.build_phases << @project.new(PBXCopyFilesBuildPhase)
        @sut.build_phases << @project.new(PBXShellScriptBuildPhase)
      end

      {
        :headers_build_phase       => PBXHeadersBuildPhase,
        :source_build_phase        => PBXSourcesBuildPhase,
        :frameworks_build_phase    => PBXFrameworksBuildPhase,
        :resources_build_phase     => PBXResourcesBuildPhase,
        :copy_files_build_phases   => PBXCopyFilesBuildPhase,
        :shell_script_build_phases => PBXShellScriptBuildPhase,
      }.each do |association_method, klass|

        it "returns an empty #{klass.isa}" do
          phase = @sut.send(association_method)
          if phase.is_a? Array
            phase = phase.first
          end

          phase.should.be.instance_of klass
          if phase.is_a? PBXFrameworksBuildPhase
            phase.files.count.should == @project.frameworks_group.files.count
          else
            phase.files.to_a.should == []
          end
        end
      end

      it "returns the frameworks build phase" do
        @sut.frameworks_build_phases.class.should == PBXFrameworksBuildPhase
      end

      it "creates a new 'copy files build phase'" do
        before = @sut.copy_files_build_phases.count
        @sut.new_copy_files_build_phase
        @sut.copy_files_build_phases.count.should == before + 1
      end

      it "creates a new 'shell script build phase'" do
        before = @sut.shell_script_build_phases.count
        @sut.new_shell_script_build_phase
        @sut.shell_script_build_phases.count.should == before + 1
      end
    end
  end

  #---------------------------------------------------------------------------#


  describe PBXNativeTarget do

    describe "In general" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
        @sut.name.should == "Pods"
        @sut.product_name.should == "Pods"
      end

      it "returns the product" do
        @sut.product_reference.should.be.instance_of PBXFileReference
        @sut.product_reference.path.should == "libPods.a"
      end

      it "returns that product type is a static library" do
        @sut.product_type.should == "com.apple.product-type.library.static"
      end

      it "returns an empty list of dependencies and build rules" do
        @sut.dependencies.to_a.should == []
        @sut.build_rules.to_a.should == []
      end
    end

    #----------------------------------------#

    describe "Helpers" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "adds a list of sources file to the target to the source build phase" do
        ref = @project.main_group.new_file('Class.m')
        @sut.add_file_references([ref], '-fobjc-arc')
        build_files = @sut.source_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Class.m'
        build_files.first.settings.should == {"COMPILER_FLAGS"=>"-fobjc-arc"}
      end

      it "adds a list of headers file to the target header build phases" do
        ref = @project.main_group.new_file('Class.h')
        @sut.add_file_references([ref], '-fobjc-arc')
        build_files = @sut.headers_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Class.h'
        build_files.first.settings.should.be.nil
      end

      it "adds a list of resources to the resources build phase" do
        ref = @project.main_group.new_file('Image.png')
        @sut.add_resources([ref])
        build_files = @sut.resources_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Image.png'
        build_files.first.settings.should.be.nil
      end

    end

  end

  #---------------------------------------------------------------------------#

end
