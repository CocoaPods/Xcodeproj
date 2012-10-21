require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe AbstractBuildPhase do

    before do
      # Can't initialize AbstractBuildPhase directly
      @phase = @project.new(PBXCopyFilesBuildPhase)
    end

    it "has an empty list of (build) files" do
      @phase.files.should == []
    end

    it "is initialized with the default buildActionMask" do
      @phase.build_action_mask.should == "2147483647"
    end

    it "is initialized with the default runOnlyForDeploymentPostprocessing" do
      @phase.run_only_for_deployment_postprocessing.should == "0"
    end

    it "can add a file reference to its build files" do
      file = @project.new_file('some/file')
      @phase.add_file_reference(file)
      @phase.files_references.should.include file
    end

    it "returns the files it's associated with through its build files" do
      file = @project.new_file('some/file')
      @phase.add_file_reference(file)
      @phase.files_references.should == [file]
    end

    it "concrete implementations subclass it" do
      concrete_classes = [
        PBXHeadersBuildPhase,
        PBXSourcesBuildPhase,
        PBXFrameworksBuildPhase,
        PBXResourcesBuildPhase,
        PBXCopyFilesBuildPhase,
        PBXShellScriptBuildPhase
      ]
      concrete_classes.each do |klass|
        (klass < AbstractBuildPhase).should.be.true
      end
    end

  end

  describe PBXCopyFilesBuildPhase do

    before do
      @phase = @project.new(PBXCopyFilesBuildPhase)
    end

    it "is a AbstractBuildPhase" do
      @phase.should.be.kind_of AbstractBuildPhase
    end

    it "returns and empty default dstPath" do
      @phase.dst_path.should == ''
    end

    it "defaults the dstSubfolderSpec to the resources folder" do
      @phase.dst_subfolder_spec.should == "7"
    end
  end

  describe PBXShellScriptBuildPhase do

    before do
      @phase = @project.new(PBXShellScriptBuildPhase)
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
