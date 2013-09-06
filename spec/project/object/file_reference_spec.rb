require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXFileReference do

    before do
      @sut = @project.new_file('File.m')
    end

    it "returns the parent" do
      @sut.parent.should == @project.main_group
    end

    it "returns the representation of the group hierarchy" do
      @sut.hierarchy_path.should == "/File.m"
    end

    it "can be moved to a new parent" do
      new_parent = @project.new_group('New Parent')
      @sut.move(new_parent)
      @sut.parent.should == new_parent
    end

    it "returns the real path" do
      @sut.real_path.should == Pathname.new('/project_dir/File.m')
    end

    it "sets the source tree" do
      @sut.source_tree = '<group>'
      @sut.set_source_tree(:absolute)
      @sut.source_tree.should == '<absolute>'
    end

    it "sets the path according to the source tree" do
      @sut.source_tree = '<group>'
      @sut.set_path('/project_dir/File.m')
      @sut.path.should == 'File.m'
    end

    it "sets its last known file type" do
      @sut.last_known_file_type = nil
      @sut.set_last_known_file_type('custom')
      @sut.last_known_file_type.should == 'custom'
    end

    it "sets its last known file type according to the extension of the path" do
      @sut.last_known_file_type = nil
      @sut.set_last_known_file_type
      @sut.last_known_file_type.should == 'sourcecode.c.objc'
    end

    it "sets its explicit file type" do
      @sut.explicit_file_type = nil
      @sut.set_explicit_file_type('custom')
      @sut.explicit_file_type.should == 'custom'
      @sut.last_known_file_type.should.be.nil
    end

    it "sets its explicit file type according to the extension of the path" do
      @sut.explicit_file_type = nil
      @sut.set_explicit_file_type
      @sut.explicit_file_type.should == 'sourcecode.c.objc'
      @sut.last_known_file_type.should.be.nil
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
