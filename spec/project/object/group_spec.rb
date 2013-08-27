require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXGroup" do

    before do
      @group = @project.new_group('Parent')
      @group.new_reference('Abracadabra.h')
      @group.new_reference('Banana.h')
      @group.new_group('ZappMachine')
      @group.new_reference('Abracadabra.m')
      @group.new_reference('Banana.m')
    end

    it "sorts by group vs file first, then name" do
      @group.new_group('Apemachine')
      @group.sort_by_type!
      @group.children.map(&:display_name).should == %w{
        Apemachine ZappMachine
        Abracadabra.h Abracadabra.m Banana.h Banana.m
      }
    end

    it "returns the parent" do
      @sut = @project.new_group('Parent')
      @sut.parent.should == @project.main_group
    end

    it "returns the real path" do
      @sut = @project.new_group('Parent')
      @sut.path = 'Classes'
      @sut.real_path.should == Pathname.new('/project_dir/Classes')
    end

    it "returns that the main group has no name" do
      @project.main_group.name.should == nil
    end

    it "returns its name" do
      @group.name.should == 'Parent'
    end

    it "creates a new reference to the file with the given path" do
      file = @group.new_reference('Class.m')
      file.parent.should == @group
    end

    it "creates a new static library" do
      file = @group.new_static_library('Pods')
      file.parent.should == @group
    end

    it "creates a new resources bundle" do
      file = @group.new_bundle('Resources')
      file.parent.should == @group
    end

    #-------------------------------------------------------------------------#

    describe "#new_group" do

      it "creates a new group" do
        group = @group.new_group('Classes')
        group.parent.should == @group
      end

      it "sets the source tree to group if not path is provided" do
        group = @group.new_group('Classes')
        group.source_tree.should == '<group>'
      end

      it "sets the path according to the source tree if provided" do
        group = @group.new_group('Classes', '/project_dir/classes')
        group.source_tree.should == '<group>'
        group.path.should == 'classes'
      end

    end

    #-------------------------------------------------------------------------#

    it "returns a list of files and groups" do
      @group.children.map(&:display_name).sort.should == %w{
        Abracadabra.h Abracadabra.m
        Banana.h Banana.m ZappMachine
      }
    end

    it "returns the recursive list of the children groups" do
      @group.new_group('group1').new_group('1')
      @group.new_group('group2').new_group('2')
      groups = @group.recursive_children_groups.map(&:display_name).sort
      groups.should == ["1", "2", "ZappMachine", "group1", "group2"]
    end

    it "removes groups and files recursively" do
      group1 = @group.new_group("Group1")
      group2 = @group.new_group("Group2")
      file1 = group2.new_reference("file1")
      file2 = group2.new_reference("file2")

      @group.remove_children_recursively
      @group.children.count.should == 0

      @project.objects_by_uuid[group1.uuid].should == nil
      @project.objects_by_uuid[group2.uuid].should == nil
      @project.objects_by_uuid[file1.uuid].should == nil
      @project.objects_by_uuid[file2.uuid].should == nil
    end

    #-------------------------------------------------------------------------#

  end
end

