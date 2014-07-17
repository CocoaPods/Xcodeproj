require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXFileReference do

    before do
      @file = @project.new_file('File.m')
    end

    it "returns the parent" do
      @file.parent.should == @project.main_group
    end

    it "returns the parents" do
      @file.parents.should == [@project.main_group]
    end

    it "returns the representation of the group hierarchy" do
      @file.hierarchy_path.should == "/File.m"
    end

    it "can be moved to a new parent" do
      new_parent = @project.new_group('New Parent')
      @file.move(new_parent)
      @file.parent.should == new_parent
    end

    it "returns the real path" do
      @file.real_path.should == Pathname.new('/project_dir/File.m')
    end

    it "sets the source tree" do
      @file.source_tree = '<group>'
      @file.set_source_tree(:absolute)
      @file.source_tree.should == '<absolute>'
    end

    it "sets the path according to the source tree" do
      @file.source_tree = '<group>'
      @file.set_path('/project_dir/File.m')
      @file.path.should == 'File.m'
    end

    it "sets its last known file type" do
      @file.last_known_file_type = nil
      @file.set_last_known_file_type('custom')
      @file.last_known_file_type.should == 'custom'
    end

    it "sets its last known file type according to the extension of the path" do
      @file.last_known_file_type = nil
      @file.set_last_known_file_type
      @file.last_known_file_type.should == 'sourcecode.c.objc'
    end

    it "sets its explicit file type" do
      @file.explicit_file_type = nil
      @file.set_explicit_file_type('custom')
      @file.explicit_file_type.should == 'custom'
      @file.last_known_file_type.should.be.nil
    end

    it "sets its explicit file type according to the extension of the path" do
      @file.explicit_file_type = nil
      @file.set_explicit_file_type
      @file.explicit_file_type.should == 'sourcecode.c.objc'
      @file.last_known_file_type.should.be.nil
    end

    it "returns whether it is a proxy" do
      @file.proxy?.should == false
    end

    it "can have associated comments, but these are no longer used by Xcode" do
      @file.comments = 'This file was automatically generated.'
      @file.comments.should == 'This file was automatically generated.'
    end
  end
end
