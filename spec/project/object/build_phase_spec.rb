require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXBuildPhase" do
    before do
      @phase = @project.objects.add(PBXBuildPhase)
    end

    it "has an empty list of files" do
      @phase.files.to_a.should == []
    end

    it "always returns the same buildActionMask (no idea what it is)" do
      @phase.build_action_mask.should == "2147483647"
    end

    it "always returns zero for runOnlyForDeploymentPostprocessing (no idea what it is)" do
      @phase.run_only_for_deployment_postprocessing.should == "0"
    end
  end

  describe "Xcodeproj::Project::Object::PBXCopyFilesBuildPhase" do
    before do
      @phase = @project.objects.add(PBXCopyFilesBuildPhase)
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of PBXBuildPhase
    end

    it "returns the dstPath" do
      @phase.dst_path.should == '$(PRODUCT_NAME)'
    end

    it "returns the dstSubfolderSpec (no idea what it is yet, but it's not always the same)" do
      @phase.dst_subfolder_spec.should == "16"
    end
  end

  describe "Xcodeproj::Project::Object::PBXSourcesBuildPhase" do
    before do
      @phase = @project.objects.add(PBXSourcesBuildPhase)
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of PBXBuildPhase
    end
  end

  describe "Xcodeproj::Project::Object::PBXFrameworksBuildPhase" do
    before do
      @phase = @project.objects.add(PBXFrameworksBuildPhase)
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of PBXBuildPhase
    end
  end

  describe "Xcodeproj::Project::Object::PBXShellScriptBuildPhase" do
    before do
      @phase = @project.objects.add(PBXShellScriptBuildPhase)
    end

    it "uses the shell in /bin/sh as the default interpreter" do
      @phase.shell_path.should == '/bin/sh'
    end

    it "has empty defaults for the other attributes" do
      @phase.files.should == []
      @phase.input_paths.should == []
      @phase.output_paths.should == []
      @phase.shell_script.should == ''
    end
  end
end
