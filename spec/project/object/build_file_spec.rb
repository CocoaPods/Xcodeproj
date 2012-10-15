require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXBuildFile do

    before do
      @file = @project.new(PBXBuildFile)
    end

    it "defaults the settings to the empty hash" do
      @file.settings.should == {}
    end

    it "returns the file reference" do
      @file.file_ref = @project.new(PBXFileReference)
      @file.file_ref.class.should == PBXFileReference
    end

    it "accepts a variant group and a version group as a reference" do
      lambda { @file.file_ref = @project.new(PBXVariantGroup) }.should.not.raise
      lambda { @file.file_ref = @project.new(XCVersionGroup) }.should.not.raise
    end

  end
end

