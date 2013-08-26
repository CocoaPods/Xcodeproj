require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXFileReference do

    before do
      @sut = @project.new_file('File.m')
    end

    it "returns the parent" do
      @sut.parent.should == @project.main_group
    end

    it "returns the real path" do
      @sut.real_path.should == Pathname.new('project_dir/File.m')
    end

    it "can update its file type according to the extension of the path" do
      @sut.last_known_file_type = nil
      @sut.update_last_known_file_type
      @sut.last_known_file_type.should == 'sourcecode.c.objc'
    end

    it "returns whether it is a proxy" do
      @sut.proxy?.should == false
    end

    it "can have associated comments, but these are no longer used by Xcode" do
      @sut.comments = 'This file was automatically generated.'
      @sut.comments.should == 'This file was automatically generated.'
    end
  end
end
