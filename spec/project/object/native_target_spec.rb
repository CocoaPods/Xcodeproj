require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXNativeTarget" do
    before do
      @target = @project.new_target(:static_library, 'Pods', :ios)
    end

    it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
      @target.name.should == "Pods"
      @target.product_name.should == "Pods"
    end

    it "returns the product" do
      @target.product_reference.should.be.instance_of PBXFileReference
      @target.product_reference.name.should == "libPods.a"
      @target.product_reference.path.should == "libPods.a"
    end

    it "adds the product to the Products group in the main group" do
      @project.products_group.files.should.include @target.product_reference
    end

    it "returns that product type is a static library" do
      @target.product_type.should == "com.apple.product-type.library.static"
    end

    it "returns an empty list of dependencies and buildRules (not sure yet which classes those are yet)" do
      @target.dependencies.to_a.should == []
      @target.build_rules.to_a.should == []
    end

    it "returns the platform name" do
      @project.new_target(:static_library, 'Pods', :ios).platform_name.should == :ios
      @project.new_target(:static_library, 'Pods', :osx).platform_name.should == :osx
    end

    it "returns the deployment_target" do
      @project.new_target(:static_library, 'Pods', :ios).deployment_target.should == '4.3'
      @project.new_target(:static_library, 'Pods', :osx).deployment_target.should == '10.7'
    end
  end

  describe "Xcodeproj::Project::Object::PBXNativeTarget, concerning its build phases" do
    before do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      @target.build_phases << @project.new(PBXCopyFilesBuildPhase)
      @target.build_phases << @project.new(PBXShellScriptBuildPhase)
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
        phase = @target.send(association_method)
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

    it "creates a new 'copy files build phase'" do
      before = @target.copy_files_build_phases.count
      @target.new_copy_files_build_phase
      @target.copy_files_build_phases.count.should == before + 1
    end

    it "creates a new 'shell script build phase'" do
      before = @target.shell_script_build_phases.count
      @target.new_shell_script_build_phase
      @target.shell_script_build_phases.count.should == before + 1
    end

    it "adds a framework in a group named 'Frameworks' in the main group to a new target" do
      framework = @project.add_system_framework('QuartzCore', :ios)
      framework_files = @project.frameworks_group.files
      target = @project.new_target(:static_library, 'Pods2', :ios)
      target.frameworks_build_phase.files_references.should == framework_files
    end
  end

  describe "A new Xcodeproj::Project::Object::PBXNativeTarget" do
    before do
      @target = @project.new_target(:static_library, 'Pods', :ios)
    end

    it "has a default set of build settings (regardless of platform)" do
      @target.build_settings('Release').should == settings(:all, :release, :ios, [:ios, :release])
      @target.build_settings('Debug').should == settings(:all, :debug, :ios, [:ios, :debug])
    end
  end

  describe "Xcodeproj::Project::Object::PBXNativeTarget, concerning its iOS specific helpers" do
    before do
      @target = @project.new_target(:static_library, 'Pods', :ios)
    end

    it "returns its name and path" do
      @target.product_name.should == 'Pods'
      @target.product_reference.path.should == 'libPods.a'
    end

    it "links against the Foundation framework" do
      frameworks = @target.frameworks_build_phase.files_references
      frameworks.map(&:name).should == ['Foundation.framework']
    end

    it "includes iOS specific build settings" do
      @target.build_settings('Release').should == settings(:all, :ios, [:ios, :release])
      @target.build_settings('Debug').should == settings(:all, :ios, :debug)
    end
  end

  describe "Xcodeproj::Project::Object::PBXNativeTarget, concerning its OS X specific helpers" do
    before do
      @target = @project.new_target(:static_library, 'Pods', :osx)
    end

    it "returns its name and path" do
      @target.product_name.should == 'Pods'
      @target.product_reference.path.should == 'libPods.a'
    end

    it "links against the Cocoa framework" do
      frameworks = @target.frameworks_build_phase.files_references
      frameworks.map(&:name).should == ['Cocoa.framework']
    end

    it "includes OS X specific build settings" do
      @target.build_settings('Release').should == settings(:all, :osx, [:osx, :release])
      @target.build_settings('Debug').should == settings(:all, :osx, :debug, [:osx, :debug])
    end
  end
end
