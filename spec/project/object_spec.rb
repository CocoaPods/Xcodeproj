require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe AbstractObject do
    describe 'In general' do
      before do
        @object = @project.new_file('Classes/file.m')
        @object.name = 'AnObject'
      end

      it 'returns its name when converting to a string' do
        @object.to_s.should == 'AnObject'
      end

      it 'returns its isa' do
        @object.isa.should == 'PBXFileReference'
      end

      it 'returns the project' do
        @object.project.should.eql @project
      end

      it 'returns its UUID' do
        @object.uuid.should.be.instance_of String
        @object.uuid.size.should == 24
      end

      it 'initializes the simple attributes with the default values' do
        @object.include_in_index.should == '1'
      end

      it 'can remove itself from the project' do
        @object.remove_from_project
        @object.referrers.count.should == 0
        @project.objects_by_uuid[@object.uuid].should.be.nil
      end

      it 'removes the itself from referred objects' do
        group = @project.new_group('Classes')
        file = group.new_reference('File.m')

        group.remove_from_project
        file.referrers.count.should == 0
        @project.objects_by_uuid[file.uuid].should.be.nil
      end

      it 'maintains the list of referrers' do
        @object.referrers.count.should == 1
        @object.referrers.first.isa.should == 'PBXGroup'
      end

      it 'can add a referrer' do
        pods = @project.new_group('Pods')
        @object.add_referrer(pods)
        @object.referrers.count.should == 2
      end

      it 'can remove a referrer' do
        @object.referrers.count.should == 1
        group = @object.referrers.first
        @object.remove_referrer(group)
        @object.referrers.count.should == 0
      end

      it 'adds itself to the project objects once it has a referrer' do
        group = @object.referrers.first
        uuid = 'uuid'
        f = PBXFileReference.new(@project, uuid)
        f.referrers.count.should == 0
        @project.objects_by_uuid[uuid].should.be.nil
        f.add_referrer(group)
        f.referrers.count.should == 1
        @project.objects_by_uuid[uuid].should == f
      end

      it 'removes itself from the project objects when it has no referrers' do
        group = @object.referrers.first
        @object.remove_referrer(group)
        @object.referrers.count.should == 0
        @project.objects_by_uuid[@object.uuid].should.be.nil
      end

      it 'can remove any reference to another object' do
        group = @object.referrers.first
        group.remove_reference(@object)
        @object.referrers.count.should == 0
      end

      it 'merges the class name into the plist representation' do
        @object.isa.should == 'PBXFileReference'
        @object.to_hash['isa'].should == 'PBXFileReference'
      end

      it 'sorts by UUID' do
        object1 = PBXFileReference.new(@project, 'uuid1')
        object2 = PBXFileReference.new(@project, 'uuid2')
        object3 = PBXFileReference.new(@project, 'uuid3')
        [object2, object1, object3].sort.should == [object1, object2, object3]
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Concerning plist serialization' do
      before do
        @objects_by_uuid_plist = {
          'uuid' => { 'name' => 'MyFile', 'isa' => 'PBXFileReference' },
        }
        @object = PBXFileReference.new(@project, 'uuid')
      end

      it 'can be configured with a plist' do
        @object.configure_with_plist(@objects_by_uuid_plist)
        @object.name.should == 'MyFile'
      end

      it 'initializes any referenced object from a plist' do
        uuid_file  = 'file_uuid'
        uuid_group = 'group_uuid'
        objects_by_uuid_plist = {
          uuid_file  => { 'name' => 'MyFile', 'isa' => 'PBXFileReference' },
          uuid_group => { 'children' => [uuid_file], 'isa' => 'PBXGroup' },
        }

        group = PBXGroup.new(@project, uuid_group)
        group.configure_with_plist(objects_by_uuid_plist)
        group.children.first.name.should == 'MyFile'
      end

      it 'ask the project for any referenced object before initializing new one' do
        uuid_file  = 'file_uuid'
        uuid_group = 'group_uuid'
        objects_by_uuid_plist = {
          uuid_file  => { 'name' => 'MyFile', 'isa' => 'PBXFileReference' },
          uuid_group => { 'children' => [uuid_file], 'isa' => 'PBXGroup' },
        }

        file = PBXFileReference.new(@project, uuid_file)
        # Add the file to the group so it is added to the objects hash
        @project.main_group << file

        group = PBXGroup.new(@project, uuid_group)
        group.configure_with_plist(objects_by_uuid_plist)
        group.children.first.equal?(file).should.be.true
        true.should.be.true
      end

      it 'discards UUIDs which cannot be found in the objects hash' do
        uuid_file  = 'file_uuid'
        uuid_group = 'group_uuid'
        objects_by_uuid_plist = {
          uuid_group => { 'children' => [uuid_file], 'isa' => 'PBXGroup' },
        }
        STDERR.expects(:puts)
        group = PBXGroup.new(@project, uuid_group)
        group.configure_with_plist(objects_by_uuid_plist)
        group.files.should.be.empty
      end

      it 'raises if it encounters an unknown attribute in a plist' do
        @objects_by_uuid_plist[@object.uuid]['unknown_attribute'] = 'might be a reference'
        lambda { @object.configure_with_plist(@objects_by_uuid_plist) }.should.raise
      end

      it 'raises if it encounters an unknown attribute in a plist' do
        @objects_by_uuid_plist[@object.uuid]['unknown_attribute'] = 'might be a reference'
        lambda { @object.configure_with_plist(@objects_by_uuid_plist) }.should.raise
      end

      it "doesn't initializes simple attributes with default values" do
        attrb = PBXFileReference.simple_attributes.find { |a| a.name == :include_in_index }
        attrb.default_value.should.be.not.nil
        @object.configure_with_plist(@objects_by_uuid_plist)
        @object.include_in_index.should.be.nil
      end

      it 'can serialize itself to a plist' do
        @object.name = 'AnObject'
        @object.source_tree = 'SOURCE_ROOT'
        @object.to_hash.should == {
          'isa'            => 'PBXFileReference',
          'name'           => 'AnObject',
          'sourceTree'     => 'SOURCE_ROOT',
        }
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Alternative representations' do
      before do
        @file = @project.new_file('Classes/file.m')
        @group = @project.main_group
      end

      it 'returns the tree representation' do
        @file.to_tree_hash.should == {
          'displayName' => 'file.m',
          'isa' => 'PBXFileReference',
          'name' => 'file.m',
          'path' => 'Classes/file.m',
          'sourceTree' => '<group>',
          'lastKnownFileType' => 'sourcecode.c.objc',
          'includeInIndex' => '1',
        }
        children = @group.to_tree_hash['children'].map { |child| child['name'] || child['path'] }
        children.should == ['Products', 'Frameworks', 'file.m']
      end

      it 'returns the pretty print representation' do
        @file.pretty_print.should == 'file.m'
        @group.pretty_print.should == {
          'Main Group' => [
            { 'Products' => [] },
            { 'Frameworks' => [] },
            'file.m',
          ],
        }
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Concerning attributes' do
      class PBXTestClass < AbstractObject
        attribute :value,   String
        has_one :file,  Xcodeproj::Project::Object::PBXFileReference
        has_many :files, Xcodeproj::Project::Object::PBXFileReference
        attribute :value_with_default, String, 'default'
      end

      before do
        @test_instance = PBXTestClass.new(@project, 'uuid')
      end

      it 'defines accessor methods for simple attributes' do
        @test_instance.value = 'a value'
        @test_instance.value.should == 'a value'
      end

      it 'defines accessor methods for to one attributes' do
        f = @project.new(PBXFileReference)
        @test_instance.file = f
        @test_instance.file.should == f
      end

      it 'defines accessor methods for to many attributes' do
        @test_instance.files.class.should == Xcodeproj::Project::ObjectList
        @test_instance.should.not.respond_to?(:files=)
      end

      it 'perform type validation for simple attributes' do
        lambda { @test_instance.value = 'string' }.should.not.raise
        lambda { @test_instance.value = [] }.should.raise
      end

      it 'perform type validation for to one attributes' do
        f = @project.new(PBXFileReference)
        lambda { @test_instance.file = f }.should.not.raise
        g = @project.new(PBXGroup)
        lambda { @test_instance.file = g }.should.raise
      end

      it 'perform type validation for to many attributes' do
        f = @project.new(PBXFileReference)
        lambda { @test_instance.files << f }.should.not.raise
        g = @project.new(PBXGroup)
        lambda { @test_instance.files << g }.should.raise
      end

      it 'adds referrers to objects of to one relationships' do
        f = @project.new(PBXFileReference)
        f.referrers.count.should == 0
        @test_instance.file = f
        f.referrers.should.include?(@test_instance)
      end

      it 'adds referrers to objects of to many relationships' do
        f = @project.new(PBXFileReference)
        f.referrers.count.should == 0
        @test_instance.files << f
        f.referrers.should.include?(@test_instance)
      end
    end

    #-------------------------------------------------------------------------#
  end
end
