require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe Workspace do
    before do
      @group = Workspace::GroupReference.new('Group Name', 'container', 'dir1/dir2')
    end

    it 'can be initialized with just the group name and have proper defaults' do
      group = Workspace::GroupReference.new('Group Name')
      group.type.should == 'container'
      group.location.should == ''
    end

    it 'properly implements equality comparison' do
      @group.should == @group.dup
      @group.should.eql @group.dup
      @group.hash.should == @group.dup.hash
    end

    it 'can be initialized by the XML representation' do
      node = REXML::Element.new('Group')
      node.attributes['location'] = 'container:dir1/dir2'
      node.attributes['name'] = 'Group Name'
      result = Workspace::GroupReference.from_node(node)
      result.should == @group
    end

    it 'returns the XML representation' do
      result = @group.to_node
      result.class.should == REXML::Element
      result.to_s.should == "<Group location='container:dir1/dir2' name='Group Name'/>"
    end

    it 'can be converted back and forth without loss of information' do
      result = Workspace::GroupReference.from_node(@group.to_node)
      result.should == @group
    end

    it 'escapes XML entities' do
      file = Workspace::GroupReference.new('"&\'><.xcodeproj', 'group')
      result = file.to_node
      result.class.should == REXML::Element
      result.to_s.should == "<Group location='group:' name='&quot;&amp;&apos;&gt;&lt;.xcodeproj'/>"
    end

    it 'prepends a parent group path, if it exists, to a path' do
      subgroup_node = REXML::Element.new('Group')
      subgroup_node.attributes['location'] = 'group:groupref_subdir/groupref'
      subgroup_node.attributes['name'] = 'Subgroup Name'

      group_node = REXML::Element.new('Group')
      group_node.attributes['location'] = 'container:dir1/dir2'
      group_node.attributes['name'] = 'Group Name'
      group_node.add_element(subgroup_node)

      groupref = Workspace::GroupReference.from_node(subgroup_node)
      groupref.location.to_s.should == 'dir1/dir2/groupref_subdir/groupref'
    end
  end
end
