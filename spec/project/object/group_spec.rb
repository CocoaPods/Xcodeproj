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

    it "returns the parent" do
      @sut = @project.new_group('Parent')
      @sut.parent.should == @project.main_group
    end

    it "returns the real path" do
      @sut = @project.new_group('Parent')
      @sut.path = 'Classes'
      @sut.real_path.should == Pathname.new('project_dir/Classes')
    end

    it "returns that the main group has no name" do
      @project.main_group.name.should == nil
    end

    it "returns its name" do
      @group.name.should == 'Parent'
    end

    describe "#new_file" do
      it "adds files for the given paths" do
        ref = @group.new_file('project_dir/ZOMG.md')
        ref.path.should == 'ZOMG.md'
        ref.include_in_index.should == '1'
        @group.children.should.include(ref)
      end

      it "set the name attribute of the file reference if the file is not in the same dir of the group" do
        ref = @group.new_file('sub_dir/ZOMG.md')
        ref.name.should == 'ZOMG.md'
      end

      it "doesn't set the name attribute of the file reference if the file is in the same dir of the group" do
        ref = @group.new_file('ZOMG.md')
        ref.name.should.be.nil
      end

      it "handles frameworks files" do
        ref = @group.new_file('Frameworks/Parse.framework')
        ref.name.should == 'Parse.framework'
        ref.include_in_index.should.be.nil
        @group.children.should.include(ref)
      end

      it "handles xcdatamodeld wrappers" do
        Pathname.any_instance.stubs(:exist?).returns(true)
        Pathname.any_instance.stubs(:children).returns([Pathname.new('Model.xcdatamodel'), Pathname.new('Model 2.xcdatamodel'),])
        ref = @group.new_file('Model.xcdatamodeld')
        ref.isa.should == 'XCVersionGroup'
        ref.path.should == 'Model.xcdatamodeld'
        ref.source_tree.should == '<group>'
        ref.version_group_type.should == 'wrapper.xcdatamodel'
        ref.children.map(&:path).should == ['Model.xcdatamodel', 'Model 2.xcdatamodel']
        ref.current_version.isa.should == 'PBXFileReference'
        ref.current_version.path.should == 'Model 2.xcdatamodel'
        ref.current_version.last_known_file_type.should == 'wrapper.xcdatamodel'
        ref.current_version.source_tree.should == '<group>'
        @group.children.should.include(ref)
      end
    end

    it "returns a list of files and groups" do
      @group.children.map(&:display_name).sort.should == %w{ Abracadabra.h Abracadabra.m Banana.h Banana.m ZappMachine }
    end

    it "returns the recursive list of the children groups" do
      @group.new_group('group1').new_group('1')
      @group.new_group('group2').new_group('2')
      groups = @group.recursive_children_groups.map(&:display_name).sort
      groups.should == ["1", "2", "ZappMachine", "group1", "group2"]
    end

    it "creates a new static library" do
      file = @group.new_static_library('Pods')
      file.name.should.be.nil
      file.path.should == 'libPods.a'
      file.include_in_index.should == '0'
      file.source_tree.should == 'BUILT_PRODUCTS_DIR'
    end

    it "creates a new resources bundle" do
      file = @group.new_bundle('Resources')
      file.name.should.be.nil
      file.path.should == 'Resources.bundle'
      file.explicit_file_type.should == 'wrapper.cfbundle'
      file.include_in_index.should == '0'
      file.source_tree.should == 'BUILT_PRODUCTS_DIR'
      file.last_known_file_type.should.be.nil
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

