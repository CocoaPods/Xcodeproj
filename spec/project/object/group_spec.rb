require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXGroup" do

    before do
      @sut = @project.new_group('Parent')
      @sut.new_reference('Abracadabra.h')
      @sut.new_reference('Banana.h')
      @sut.new_group('ZappMachine')
      @sut.new_reference('Abracadabra.m')
      @sut.new_reference('Banana.m')
    end

    it "returns the parent" do
      @sut.parent.should == @project.main_group
    end

    it "returns the parents" do
      @sut.parents.should == [@project.main_group]
    end

    it "returns the representation of the group hierarchy" do
      group = @sut.new_group('Child')
      group.hierarchy_path.should == "/Parent/Child"
    end

    it "can be moved to a new parent" do
      new_parent = @project.new_group('New Parent')
      group = @sut.new_group('Child')
      group.move(new_parent)
      group.parent.should == new_parent
    end

    it "returns the real path" do
      @sut.path = 'Classes'
      @sut.real_path.should == Pathname.new('/project_dir/Classes')
    end

    it "sets the source tree" do
      @sut.source_tree = '<group>'
      @sut.set_source_tree(:absolute)
      @sut.source_tree.should == '<absolute>'
    end

    #----------------------------------------#

    describe "#set_path" do

      it "sets the path according to the source tree" do
        @sut.source_tree = '<group>'
        @sut.set_path('/project_dir/Classes')
        @sut.path.should == 'Classes'
      end

      it "sets the source tree to group if the given path is nil" do
        @sut.source_tree = '<absolute>'
        @sut.path = '/project_dir/Classes'
        @sut.set_path(nil)
        @sut.path.should.be.nil
        @sut.source_tree.should == '<group>'
      end

    end

    #----------------------------------------#

    it "returns a list of files" do
      @sut.files.map(&:display_name).sort.should == %w{
        Abracadabra.h Abracadabra.m
        Banana.h Banana.m
      }
    end

    it "returns the file matching the given path" do
      @sut.find_file_by_path('Abracadabra.h').display_name.should == 'Abracadabra.h'
    end

    it "returns a list of groups" do
      @sut.groups.map(&:display_name).sort.should == %w{ ZappMachine }
    end

    it "returns the recursive list of the children groups" do
      @sut.new_group('group1').new_group('1')
      @sut.new_group('group2').new_group('2')
      groups = @sut.recursive_children_groups.map(&:display_name).sort
      groups.should == ["1", "2", "ZappMachine", "group1", "group2"]
    end

    it "returns whether it is empty" do
      @sut.should.not.be.empty
      @project.new_group('Another').should.be.empty
    end

    it "creates a new reference to the file with the given path" do
      file = @sut.new_reference('Class.m')
      file.parent.should == @sut
    end

    it "creates a new static library" do
      file = @sut.new_product_ref_for_target('Pods', :static_library)
      file.parent.should == @sut
    end

    it "creates a new resources bundle" do
      file = @sut.new_bundle('Resources')
      file.parent.should == @sut
    end

    #-------------------------------------------------------------------------#

    describe "#new_group" do

      it "creates a new group" do
        group = @sut.new_group('Classes')
        group.parent.should == @sut
      end

      it "sets the source tree to group if not path is provided" do
        group = @sut.new_group('Classes')
        group.source_tree.should == '<group>'
      end

      it "sets the path according to the source tree if provided" do
        group = @sut.new_group('Classes', '/project_dir/classes')
        group.source_tree.should == '<group>'
        group.path.should == 'classes'
      end

    end

    #-------------------------------------------------------------------------#

    it "removes groups and files recursively" do
      group1 = @sut.new_group("Group1")
      group2 = @sut.new_group("Group2")
      file1 = group2.new_reference("file1")
      file2 = group2.new_reference("file2")

      @sut.remove_children_recursively
      @sut.children.count.should == 0

      @project.objects_by_uuid[group1.uuid].should == nil
      @project.objects_by_uuid[group2.uuid].should == nil
      @project.objects_by_uuid[file1.uuid].should == nil
      @project.objects_by_uuid[file2.uuid].should == nil
    end

    #----------------------------------------#

    describe "#sort_by_type" do

      before do
        @sut = @project.new_group('test')
      end

      it "sorts by group vs file first, then name" do
        @sut.new_file('FA')
        @sut.new_file('FB')
        @sut.new_group('GB')
        @sut.new_group('GA')
        @sut.sort_by_type
        @sut.children.map(&:display_name).should == %w{ GA GB FA FB }
      end

      it "doesn't treat PBXVariantGroup as a group for sorting purposes" do
        group = @project.new('PBXVariantGroup')
        group.name = 'B.xib'
        @sut.new_file('A.xib')
        @sut.children << group
        @sut.sort_by_type
        @sut.children.map(&:display_name).should == ["A.xib", "B.xib"]
      end

      it "doesn't treat XCVersionGroup as a group for sorting purposes" do
        group = @project.new('XCVersionGroup')
        group.name = 'Z'
        @sut.children << group
        @sut.sort_by_type
        @sut.children.last.name.should == 'Z'
      end

      it "sorts by display name if available" do
        @sut = @project.new_group('test')
        f_1 = @project.new('PBXFileReference')
        f_2 = @project.new('PBXFileReference')
        f_3 = @project.new('PBXFileReference')
        f_1.name = 'A'
        f_2.path = 'B'
        f_3.name = 'C'
        @sut << f_3 << f_2 << f_1
        @sut.sort_by_type
        @sut.children.map(&:display_name).should == ["A", "B", "C"]
      end

      it "sorts by base name if the extensions match" do
        @sut = @project.new_group('test')
        files = %w[
        MagicalRecord.h
        MagicalRecord.m
        MagicalRecord+Actions.h
        MagicalRecord+Actions.m
        ]
        files.each do |file|
          @sut.new_file(file)
        end
        @sut.sort_by_type
        @sut.children.map(&:display_name).should == [
          "MagicalRecord.h",
          "MagicalRecord+Actions.h",
          "MagicalRecord.m",
          "MagicalRecord+Actions.m",
        ]
      end
    end

    #----------------------------------------#

    it "recursively sorts by type" do
      subgroup = @sut.new_group('Apemachine')
      subgroup.new_file('Orange.m')
      subgroup.new_group('Orangemachine')
      @sut.recursively_sort_by_type
      @sut.children.map(&:display_name).should == %w{
        Apemachine ZappMachine
        Abracadabra.h
        Banana.h
        Abracadabra.m
        Banana.m
      }
      subgroup.children.map(&:display_name).should == %w{
        Orangemachine Orange.m
      }
    end

    describe "AbstractObject Hooks" do

      describe "#sort" do

        before do
          @sut = @project.new_group('test')
        end

        it "sorts by name by default" do
          files = %w[ B.m A.h B.h A.m ]
          files.each do |file|
            @sut.new_file(file)
          end
          @sut.sort

          @sut.children.map(&:display_name).should == %w[ A.h A.m B.h B.m ]
        end

        it "sorts first by basename and then by extension" do
          files = %w[
            MagicalRecord.h
            MagicalRecord.m
            MagicalRecord+Actions.h
            MagicalRecord+Actions.m
          ]
          files.each do |file|
            @sut.new_file(file)
          end
          @sut.sort

          @sut.children.map(&:display_name).should == [
            "MagicalRecord.h",
            "MagicalRecord.m",
            "MagicalRecord+Actions.h",
            "MagicalRecord+Actions.m",
          ]
        end

      end

    end

    #-------------------------------------------------------------------------#

  end
end

