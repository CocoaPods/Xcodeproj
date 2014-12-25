require File.expand_path('../spec_helper', __FILE__)

def options
  {
    :key_1 => 'v1',
    :key_2 => 'v2',
  }
end

module Xcodeproj
  describe Differ do
    describe 'Hashes' do
      it 'returns the nil if the hashes are equal' do
        v1 = { :add => 'add' }
        diff = Differ.hash_diff(v1, v1, options)
        diff.should.nil?
      end

      it 'returns the whether a key was added to the first array' do
        v1 = { :add => 'add' }
        v2 = {}
        diff = Differ.hash_diff(v1, v2, options)
        diff.should == { :add => { 'v1' => 'add', 'v2' => nil } }
      end

      it 'returns the whether a key was added to the second array' do
        v1 = {}
        v2 = { :add => 'add' }
        diff = Differ.hash_diff(v1, v2, options)
        diff.should == { :add => { 'v1' => nil, 'v2' => 'add' } }
      end

      it 'returns the whether the value of a key has changed' do
        v1 = { :key => '123' }
        v2 = { :key => '456' }
        diff = Differ.hash_diff(v1, v2, options)
        diff.should == { :key => { 'v1' => '123', 'v2' => '456' } }
      end

      it 'handles keys which contain arrays' do
        v1 = { :key => [1, 2, 3] }
        v2 = { :key => [1, 2, 4] }
        diff = Differ.hash_diff(v1, v2, options)
        diff.should == { :key => { 'v1' => [3], 'v2' => [4] } }
      end

      it 'handles nested arrays' do
        v1 = { :key => { :subvalue_1 => { :entry_1 => 'A' }, :subvalue_2 => { :entry_1 => 'A' } } }
        v2 = { :key => { :subvalue_1 => { :entry_1 => 'A' }, :subvalue_2 => { :entry_1 => 'B' } } }
        diff = Differ.hash_diff(v1, v2, options)
        diff.should == { :key => { :subvalue_2 => { :entry_1 => { 'v1' => 'A', 'v2' => 'B' } } } }
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Arrays' do
      it 'returns the nil if the arrays are equal' do
        v1 = [1, 2, 3]
        diff = Differ.array_diff(v1, v1, options)
        diff.should.nil?
      end

      it 'returns the diff of two arrays' do
        v1 = [1, 2, 3]
        v2 = [1, 2, 4]
        diff = Differ.array_diff(v1, v2, options)
        diff.should == { 'v1' => [3], 'v2' => [4] }
      end

      it 'returns the diff of two arrays containing an hash' do
        v1 = [{ :key => 'value_1' }]
        v2 = [{ :key => 'value_2' }]
        diff = Differ.array_diff(v1, v2, options)
        diff.should == {
          'v1' => [{ :key => 'value_1' }],
          'v2' => [{ :key => 'value_2' }],
        }
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Generic diff' do
      it 'returns nil as the diff of two equal objects' do
        v1 = 'String'
        v2 = 'String'
        diff = Differ.generic_diff(v1, v2, options)
        diff.should.be.nil
      end

      it 'returns the diff of two objects which do not represent a collection' do
        v1 = 'String_1'
        v2 = 'String_2'
        diff = Differ.generic_diff(v1, v2, options)
        diff.should == { 'v1' => 'String_1', 'v2' => 'String_2' }
      end

      it 'handles the case where one of the values is a collection object' do
        v1 = ['String_1']
        v2 = 'String_2'
        diff = Differ.generic_diff(v1, v2, options)
        diff.should == { 'v1' => ['String_1'], 'v2' => 'String_2' }
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Cleaning' do
      it 'cleans an hash from the given key' do
        hash = { :key => 'v1', :delete => 'v2' }
        Differ.clean_hash!(hash, :delete)
        hash.should == { :key => 'v1' }
      end

      it 'cleans an hash from the given key non destructively' do
        hash  = { :key => 'v1', :delete => 'v2' }
        clean = Differ.clean_hash(hash, :delete)
        clean.should == { :key => 'v1' }
        hash.should == { :key => 'v1', :delete => 'v2' }
      end
    end

    #-------------------------------------------------------------------------#

    describe '#diff' do
      it 'returns nil as the diff of two equal objects' do
        v1 = { :key => ['String'] }
        v2 = { :key => ['String'] }
        diff = Differ.diff(v1, v2, options)
        diff.should.be.nil
      end

      it 'handles hashes' do
        v1 = { :key => 'value_1' }
        v2 = { :key => 'value_2' }
        diff = Differ.diff(v1, v2, options)
        diff.should == { :key => { 'v1' => 'value_1', 'v2' => 'value_2' } }
      end

      it 'handles arrays' do
        v1 = ['value_1']
        v2 = ['value_2']
        diff = Differ.diff(v1, v2, options)
        diff.should == { 'v1' => ['value_1'], 'v2' => ['value_2'] }
      end

      it 'handles generic objects' do
        v1 = 'value_1'
        v2 = 'value_2'
        diff = Differ.diff(v1, v2, options)
        diff.should == { 'v1' => 'value_1', 'v2' => 'value_2' }
      end
    end

    #-------------------------------------------------------------------------#

    describe '#project_diff' do
      it 'provides a succint diff of a project' do
        project_1 = {
          'mainGroup' => {
            'displayName' => 'Main Group', 'isa' => 'PBXGroup', 'sourceTree' => '<group>',
            'children' => [
              { 'displayName' => 'A Group', 'isa' => 'PBXGroup', 'sourceTree' => '<group>', 'name' => 'Products', 'children' =>                [
                { 'displayName' => 'file_1.m', 'isa' => 'PBXFileReference', 'path' => 'path/file_1.m' },
              ]
            },
            ]
          },
        }

        project_2 = {
          'mainGroup' => {
            'displayName' => 'Main Group', 'isa' => 'PBXGroup', 'sourceTree' => '<group>',
            'children' => [
              { 'displayName' => 'A Group', 'isa' => 'PBXGroup', 'sourceTree' => '<group>', 'name' => 'Products', 'children' =>                [
                { 'displayName' => 'file_1.m', 'isa' => 'PBXFileReference', 'path' => 'new_path/file_1.m' },
              ]
            },
            ]
          },
        }

        diff = Differ.project_diff(project_1, project_2)
        diff.should == {
          'mainGroup' => {
            'children' => {
              'A Group' => {
                'children' => {
                  'file_1.m' => {
                    'path' => {
                      'project_1' => 'path/file_1.m',
                      'project_2' => 'new_path/file_1.m' },
                  },
                },
              },
            },
          },
        }
      end
    end

    #-------------------------------------------------------------------------#
  end

  #-------------------------------------------------------------------------#

  # TODO: delete
  describe Hash do
    it 'returns the recursive diff with another hash' do
      v1 = { :common => 'value', :changed => 'v1' }
      v2 = { :common => 'value', :changed => 'v2', :addition => 'new_value' }

      v1.recursive_diff(v2).should == {
        :changed => {
          'self'  => 'v1',
          'other' => 'v2',
        },
        :addition => {
          'self'  => nil,
          'other' => 'new_value',
        },
      }
    end
  end
end
