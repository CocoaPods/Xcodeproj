require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXGroup" do
    before do
      @group = @project.new_group('Parent')
      @group.new_file('Abracadabra.h')
      @group.new_file('Banana.h')
      @group.new_group('ZappMachine')
      @group.new_file('Abracadabra.m')
      @group.new_file('Banana.m')
    end

    it "sorts by group vs file first, then name" do
      @group.new_group('Apemachine')
      @group.sort_by_type!
      @group.children.map(&:display_name).should == %w{
        Apemachine ZappMachine
        Abracadabra.h Abracadabra.m Banana.h Banana.m
      }
    end

    it "creates nested groups" do
      @project.new_group('groups', 'some/dir/and/sub/groups')

      groups = @project.main_group.groups
      %w{some dir and sub groups}.each do |group_name|
        group = groups.select { |g| g.name == group_name }.first
        group.should.not == nil
        groups = group.groups
      end
    end

    it "returns that the main group has no name" do
      @project.main_group.name.should == nil
    end

    it "returns its name" do
      @group.name.should == 'Parent'
    end

    it "adds files for the given paths" do
      ref = @group.new_file('ZOMG.md')
      ref.path.should == 'ZOMG.md'
      ref.include_in_index.should == '1'
      @group.files.should.include ref
    end

    it "set the name attribute of the file reference if the file is not in the same dir of the group" do
      ref = @group.new_file('sub_dir/ZOMG.md')
      ref.name.should == 'ZOMG.md'
    end

    it "doesn't set the name attribute of the file reference if the file is in the same dir of the group" do
      ref = @group.new_file('ZOMG.md')
      ref.name.should.be.nil
    end

    it "configures frameworks files" do
      ref = @group.new_file('Frameworks/Parse.framework')
      ref.name.should == 'Parse.framework'
      ref.include_in_index.should.be.nil
    end

    it "returns a list of files and groups" do
      @group.children.map(&:display_name).sort.should == %w{ Abracadabra.h Abracadabra.m Banana.h Banana.m ZappMachine }
    end

    it "returns the recursive list of the children groups" do
      @group.new_group('1', 'group1')
      @group.new_group('2', 'group2')
      groups = @group.recursive_children_groups.map(&:display_name).sort
      groups.should == ["1", "2", "ZappMachine", "group1", "group2"]
    end

    it "adds XCVersionGroups" do
      group = @group.new_xcdatamodel_group('some/Model.xcdatamodeld')
      group.isa.should == 'XCVersionGroup'
      group.source_tree.should == '<group>'
      group.version_group_type.should == 'wrapper.xcdatamodel';
    end

    it "creates a new static library" do
      file = @group.new_static_library('libPods.a')
      file.include_in_index.should == '0'
      file.source_tree.should == 'BUILT_PRODUCTS_DIR'
    end

    it "removes groups and files recursively" do
      group1 = @group.new_group("Group1")
      group2 = @group.new_group("Group2")
      file1 = group2.new_file("file1")
      file2 = group2.new_file("file2")

      @group.remove_children_recursively
      @group.children.count.should == 0

      @project.objects_by_uuid[group1.uuid].should == nil
      @project.objects_by_uuid[group2.uuid].should == nil
      @project.objects_by_uuid[file1.uuid].should == nil
      @project.objects_by_uuid[file2.uuid].should == nil
    end
  end
end

