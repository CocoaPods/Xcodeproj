require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXBuildFile do

    before do
      @sut = @project.new(PBXBuildFile)
    end

    describe "In general" do

      it "doesn't provide default file settings" do
        @sut.settings.should.be.nil
      end

      it "returns the file reference" do
        @sut.file_ref = @project.new(PBXFileReference)
        @sut.file_ref.class.should == PBXFileReference
      end

      it "accepts a group as a reference" do
        lambda { @sut.file_ref = @project.new(PBXGroup) }.should.not.raise
      end

      it "accepts a variant group and a version group as a reference" do
        lambda { @sut.file_ref = @project.new(PBXVariantGroup) }.should.not.raise
        lambda { @sut.file_ref = @project.new(XCVersionGroup) }.should.not.raise
      end

    end

    #-------------------------------------------------------------------------#

    describe "AbstractObject Hooks" do

      it "returns the display name of the file reference if one is available" do
        file_ref = @project.new_file('Class.m')
        @sut.file_ref = file_ref
        @sut.display_name.should == 'Class.m'
      end

      it "returns the class name as the display name if no file reference is associated" do
        @sut.display_name.should == 'BuildFile'
      end

      it "returns the pretty print representation" do
        @sut.file_ref = @project.new_file('Class.m')
        @sut.settings = {}
        @sut.settings['COMPILER_FLAGS'] = '-Wno-format'
        @sut.pretty_print.should =={
          "Class.m" => { "COMPILER_FLAGS" => "-Wno-format" }
        }
      end

    end

    #-------------------------------------------------------------------------#



  end
end

