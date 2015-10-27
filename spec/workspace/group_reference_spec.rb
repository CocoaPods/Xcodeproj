require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe Workspace do
    before do
      @group = Workspace::GroupReference.new('Group Name', 'container')
    end

    it 'properly implements equality comparison' do
      @group.should == @group.dup
      @group.should.eql @group.dup
      @group.hash.should == @group.dup.hash
    end

    it 'can be initialized by the XML representation' do
      node = REXML::Element.new('Group')
      node.attributes['location'] = 'container:'
      node.attributes['name'] = 'Group Name'
      result = Workspace::GroupReference.from_node(node)
      result.should == @group
    end

    it 'returns the XML representation' do
      result = @group.to_node
      result.class.should == REXML::Element
      result.to_s.should == "<Group location='container:' name='Group Name'/>"
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
  end
end
