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
      @phase.buildActionMask.should == "2147483647"
    end

    it "always returns zero for runOnlyForDeploymentPostprocessing (no idea what it is)" do
      @phase.runOnlyForDeploymentPostprocessing.should == "0"
    end
  end

  describe "Xcodeproj::Project::Object::PBXCopyFilesBuildPhase" do
    before do
      @phase = @project.objects.add(PBXCopyFilesBuildPhase, 'dstPath' => 'some/path')
    end

    it "is a PBXBuildPhase" do
      @phase.should.be.kind_of PBXBuildPhase
    end

    it "returns the dstPath" do
      @phase.dstPath.should == 'some/path'
    end

    it "returns the dstSubfolderSpec (no idea what it is yet, but it's not always the same)" do
      @phase.dstSubfolderSpec.should == "16"
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
end
