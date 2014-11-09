require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe Workspace do
    before do
      @file = Workspace::FileReference.new('project.xcodeproj', 'group')
    end

    it 'properly implements equality comparison' do
      @file.should == @file.dup
      @file.should.eql @file.dup
      @file.hash.should == @file.dup.hash
    end

    it 'can be initialized by the XML representation' do
      node = REXML::Element.new('FileRef')
      node.attributes['location'] = 'group:project.xcodeproj'
      result = Workspace::FileReference.from_node(node)
      result.should == @file
    end

    it 'returns the XML representation' do
      result = @file.to_node
      result.class.should == REXML::Element
      result.to_s.should == "<FileRef location='group:project.xcodeproj'/>"
    end

    it 'can be converted back and forth without loss of information' do
      result = Workspace::FileReference.from_node(@file.to_node)
      result.should == @file
    end

    it 'returns the absolute path for group types' do
      result = @file.absolute_path('/path/to/')
      result.should == '/path/to/project.xcodeproj'
    end

    it 'returns the absolute path for container types' do
      @file.stubs(:type).returns('container')
      result = @file.absolute_path('/path/to/')
      result.should == '/path/to/project.xcodeproj'
    end

    it 'returns the absolute path for absolute types' do
      @file.stubs(:type).returns('absolute')
      result = @file.absolute_path('/path/to/')
      result.should == File.expand_path(@file.path)
    end

    it 'escapes XML entities' do
      file = Workspace::FileReference.new('"&\'><.xcodeproj', 'group')
      result = file.to_node
      result.class.should == REXML::Element
      result.to_s.should == "<FileRef location='group:&quot;&amp;&apos;&gt;&lt;.xcodeproj'/>"
    end
  end
end
