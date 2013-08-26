require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::GroupableHelper do

    before do
      @sut = GroupableHelper
    end

    before do
      @group = @project.new_group('Parent')
    end

    it "returns the parent" do
      @sut.parent(@group).should == @project.main_group
    end

    it "returns the real path of an object" do
      @group.source_tree = '<group>'
      @group.path = 'Classes'
      @sut.real_path(@group).should == Pathname.new('project_dir/Classes')
    end

    #----------------------------------------#

    describe '::source_tree_real_path' do

      it "returns the source tree of an absolute path" do
        @group.source_tree = '<absolute>'
        @sut.source_tree_real_path(@group).should == Pathname.new('/')
      end

      it "returns the source tree of a path relative to main group" do
        @group.source_tree = '<group>'
        @sut.source_tree_real_path(@group).should == Pathname.new('project_dir')
      end

      it "returns the source tree of a path relative to a group" do
        @group.source_tree = '<absolute>'
        @group.path = 'parent_group_path'
        children = @group.new_group('child')
        children.source_tree = '<group>'
        children.path = 'dir'
        @sut.source_tree_real_path(children).should == Pathname.new('/parent_group_path')
      end

      it "returns the source tree of a path relative to the project root" do
        @group.source_tree = 'SOURCE_ROOT'
        @sut.source_tree_real_path(@group).should == Pathname.new('project_dir')
      end

      it "raises if unable to resolve the source tree" do
        should.raise do
          @group.source_tree = 'DEVELOPER_DIR'
          @sut.source_tree_real_path(@group).should == Pathname.new('project_dir')
        end.message.should.match /Unable to compute the source tree/
      end

    end

    #---------------------------------------------------------------------#

  end
end
