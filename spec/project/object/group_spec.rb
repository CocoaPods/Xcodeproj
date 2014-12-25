require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe 'Xcodeproj::Project::Object::PBXGroup' do
    before do
      @group = @project.new_group('Parent')
      @group.new_reference('Abracadabra.h')
      @group.new_reference('Banana.h')
      @group.new_group('ZappMachine')
      @group.new_reference('Abracadabra.m')
      @group.new_reference('Banana.m')
    end

    it 'returns the parent' do
      @group.parent.should == @project.main_group
    end

    it 'returns the parents' do
      @group.parents.should == [@project.main_group]
    end

    it 'returns the representation of the group hierarchy' do
      group = @group.new_group('Child')
      group.hierarchy_path.should == '/Parent/Child'
    end

    it 'can be moved to a new parent' do
      new_parent = @project.new_group('New Parent')
      group = @group.new_group('Child')
      group.move(new_parent)
      group.parent.should == new_parent
    end

    it 'returns the real path' do
      @group.path = 'Classes'
      @group.real_path.should == Pathname.new('/project_dir/Classes')
    end

    it 'sets the source tree' do
      @group.source_tree = '<group>'
      @group.set_source_tree(:absolute)
      @group.source_tree.should == '<absolute>'
    end

    #----------------------------------------#

    describe '#set_path' do
      it 'sets the path according to the source tree' do
        @group.source_tree = '<group>'
        @group.set_path('/project_dir/Classes')
        @group.path.should == 'Classes'
      end

      it 'sets the source tree to group if the given path is nil' do
        @group.source_tree = '<absolute>'
        @group.path = '/project_dir/Classes'
        @group.set_path(nil)
        @group.path.should.be.nil
        @group.source_tree.should == '<group>'
      end
    end

    #----------------------------------------#

    it 'returns a list of files' do
      @group.files.map(&:display_name).sort.should == %w(
        Abracadabra.h Abracadabra.m
        Banana.h Banana.m
      )
    end

    it 'returns the file matching the given path' do
      @group.find_file_by_path('Abracadabra.h').display_name.should == 'Abracadabra.h'
    end

    it 'returns a list of groups' do
      @group.groups.map(&:display_name).sort.should == %w(ZappMachine)
    end

    it 'returns the recursive list of the children groups' do
      @group.new_group('group1').new_group('1')
      @group.new_group('group2').new_group('2')
      groups = @group.recursive_children_groups.map(&:display_name).sort
      groups.should == %w(1 2 ZappMachine group1 group2)
    end

    it 'returns the recursive list of the children' do
      @group.new_group('group1').new_group('1')
      @group.new_group('group2').new_group('2')
      groups = @group.recursive_children.map(&:display_name).sort
      groups.should == ['1', '2', 'Abracadabra.h', 'Abracadabra.m', 'Banana.h', 'Banana.m', 'ZappMachine', 'group1', 'group2']
    end

    it 'returns whether it is empty' do
      @group.should.not.be.empty
      @project.new_group('Another').should.be.empty
    end

    it 'creates a new reference to the file with the given path' do
      file = @group.new_reference('Class.m')
      file.parent.should == @group
    end

    it 'creates a new static library' do
      file = @group.new_product_ref_for_target('Pods', :static_library)
      file.parent.should == @group
    end

    it 'creates a new resources bundle' do
      file = @group.new_bundle('Resources')
      file.parent.should == @group
    end

    #-------------------------------------------------------------------------#

    describe '#new_group' do
      it 'creates a new group' do
        group = @group.new_group('Classes')
        group.parent.should == @group
      end

      it 'sets the source tree to group if not path is provided' do
        group = @group.new_group('Classes')
        group.source_tree.should == '<group>'
      end

      it 'sets the path according to the source tree if provided' do
        group = @group.new_group('Classes', '/project_dir/classes')
        group.source_tree.should == '<group>'
        group.path.should == 'classes'
      end
    end

    #-------------------------------------------------------------------------#

    it 'removes groups and files recursively' do
      group1 = @group.new_group('Group1')
      group2 = @group.new_group('Group2')
      file1 = group2.new_reference('file1')
      file2 = group2.new_reference('file2')

      @group.remove_children_recursively
      @group.children.count.should == 0

      @project.objects_by_uuid[group1.uuid].should.nil?
      @project.objects_by_uuid[group2.uuid].should.nil?
      @project.objects_by_uuid[file1.uuid].should.nil?
      @project.objects_by_uuid[file2.uuid].should.nil?
    end

    #----------------------------------------#

    describe '#sort_by_type' do
      before do
        @group = @project.new_group('test')
      end

      it 'sorts by group vs file first, then name' do
        @group.new_file('FA')
        @group.new_file('FB')
        @group.new_group('GB')
        @group.new_group('GA')
        @group.sort_by_type
        @group.children.map(&:display_name).should == %w(GA GB FA FB)
      end

      it "doesn't treat PBXVariantGroup as a group for sorting purposes" do
        group = @project.new('PBXVariantGroup')
        group.name = 'B.xib'
        @group.new_file('A.xib')
        @group.children << group
        @group.sort_by_type
        @group.children.map(&:display_name).should == ['A.xib', 'B.xib']
      end

      it "doesn't treat XCVersionGroup as a group for sorting purposes" do
        group = @project.new('XCVersionGroup')
        group.name = 'Z'
        @group.children << group
        @group.sort_by_type
        @group.children.last.name.should == 'Z'
      end

      it 'sorts by display name if available' do
        @group = @project.new_group('test')
        f_1 = @project.new('PBXFileReference')
        f_2 = @project.new('PBXFileReference')
        f_3 = @project.new('PBXFileReference')
        f_1.name = 'A'
        f_2.path = 'B'
        f_3.name = 'C'
        @group << f_3 << f_2 << f_1
        @group.sort_by_type
        @group.children.map(&:display_name).should == %w(A B C)
      end

      it 'sorts by base name if the extensions match' do
        @group = @project.new_group('test')
        files = %w(
          MagicalRecord.h
          MagicalRecord.m
          MagicalRecord+Actions.h
          MagicalRecord+Actions.m
        )
        files.each do |file|
          @group.new_file(file)
        end
        @group.sort_by_type
        @group.children.map(&:display_name).should == [
          'MagicalRecord.h',
          'MagicalRecord+Actions.h',
          'MagicalRecord.m',
          'MagicalRecord+Actions.m',
        ]
      end
    end

    #----------------------------------------#

    it 'recursively sorts by type' do
      subgroup = @group.new_group('Apemachine')
      subgroup.new_file('Orange.m')
      subgroup.new_group('Orangemachine')
      @group.sort_recursively_by_type
      @group.children.map(&:display_name).should == %w(
        Apemachine ZappMachine
        Abracadabra.h
        Banana.h
        Abracadabra.m
        Banana.m
      )
      subgroup.children.map(&:display_name).should == %w(
        Orangemachine Orange.m
      )
    end

    describe 'AbstractObject Hooks' do
      describe '#sort' do
        before do
          @group = @project.new_group('test')
        end

        it 'sorts by name by default' do
          files = %w(B.m A.h B.h A.m)
          files.each do |file|
            @group.new_file(file)
          end
          @group.sort

          @group.children.map(&:display_name).should == %w(A.h A.m B.h B.m)
        end

        it 'sorts first by basename and then by extension' do
          files = %w(
            MagicalRecord.h
            MagicalRecord.m
            MagicalRecord+Actions.h
            MagicalRecord+Actions.m
          )
          files.each do |file|
            @group.new_file(file)
          end
          @group.sort

          @group.children.map(&:display_name).should == [
            'MagicalRecord.h',
            'MagicalRecord.m',
            'MagicalRecord+Actions.h',
            'MagicalRecord+Actions.m',
          ]
        end

        it 'can sort groups above' do
          files = %w(B.m A.h B.h A.m)
          files.each do |file|
            @group.new_file(file)
          end
          @group.new_group('Z')

          @group.sort(:groups_position => :above)
          @group.children.map(&:display_name).should == %w(Z A.h A.m B.h B.m)
        end

        it 'can sort groups below' do
          files = %w(B.m A.h B.h A.m)
          files.each do |file|
            @group.new_file(file)
          end
          @group.new_group('A')

          @group.sort(:groups_position => :below)
          @group.children.map(&:display_name).should == %w(A.h A.m B.h B.m A)
        end
      end
    end

    #-------------------------------------------------------------------------#
  end
end
