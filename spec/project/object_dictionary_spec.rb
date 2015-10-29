require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ObjectDictionary do
    before do
      attribute = AbstractObjectAttribute.new(:references_by_keys, :project_references, PBXProject)
      attribute.classes = [PBXFileReference, PBXGroup]
      attribute.classes_by_key = {
        :project_ref   => PBXFileReference,
        :product_group => PBXGroup,
      }
      @dictionary = Xcodeproj::Project::ObjectDictionary.new(attribute, @project.root_object)
    end

    describe 'In general' do
      it 'returns the list of the allowed keys' do
        @dictionary.allowed_keys.map(&:to_s).sort.should ==
          %w(product_group project_ref)
      end
    end

    describe 'Notification enabled methods' do
      it 'stores an object' do
        object = @project.new(PBXFileReference)
        @dictionary[:project_ref] = object
        @dictionary[:project_ref].should == object
      end

      it 'normalizes the key if needed' do
        object = @project.new(PBXFileReference)
        @dictionary['ProjectRef'] = object
        @dictionary[:project_ref].should == object
      end

      it 'raises if a non allowed key is given' do
        object = @project.new(PBXFileReference)
        should.raise do
          @dictionary[:not_allowed] = object
        end.message.should.include 'Unsupported key'
      end

      it 'raises if a non allowed ISA for the key is given' do
        object = @project.new(PBXGroup)
        should.raise do
          @dictionary[:project_ref] = object
        end.message.should.include 'Type checking error'
      end

      it 'informs an object that is has been added to the dictionary' do
        f = @dictionary[:project_ref] = @project.new(PBXFileReference)
        f.referrers.should.include?(@project.root_object)
      end

      it 'informs an object that the referenced stopped if its associated key is set to nil' do
        f = @dictionary[:project_ref] = @project.new(PBXFileReference)
        f.referrers.count.should == 1
        f.referrers.should.include?(@project.root_object)
        @dictionary[:project_ref] = nil
        f.referrers.count.should == 0
      end

      it 'informs an object that the referenced stopped if its associated key is deleted' do
        f = @dictionary[:project_ref] = @project.new(PBXFileReference)
        f.referrers.count.should == 1
        f.referrers.should.include?(@project.root_object)
        @dictionary.delete(:project_ref)
        f.referrers.count.should == 0
      end
    end

    describe 'AbstractObject methods' do
      before do
        @dictionary[:project_ref] = @project.new(PBXFileReference)
        @dictionary[:product_group] = @project.new(PBXGroup)
      end

      it 'returns the plist representation of the dictionary' do
        project_ref_uuid = @dictionary[:project_ref].uuid
        product_group_uuid = @dictionary[:product_group].uuid
        @dictionary.to_hash.should == {
          'ProjectRef' => project_ref_uuid,
          'ProductGroup' => product_group_uuid,
        }
      end

      it 'returns the to tree hash representation of the dictionary' do
        @dictionary[:project_ref].name = 'A project'
        @dictionary[:project_ref].path = 'A path'
        @dictionary[:product_group].name = 'Products'
        @dictionary.to_tree_hash.should == {
          'ProjectRef' => {
            'displayName' => 'A project',
            'isa' => 'PBXFileReference',
            'name' => 'A project',
            'path' => 'A path',
            'sourceTree' => 'SOURCE_ROOT',
            'includeInIndex' => '1',
          },
          'ProductGroup' => {
            'displayName' => 'Products',
            'isa' => 'PBXGroup',
            'sourceTree' => '<group>',
            'name' => 'Products',
            'children' => [],
          },
        }
      end
    end
  end
end
