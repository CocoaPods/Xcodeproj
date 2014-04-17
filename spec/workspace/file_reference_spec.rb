require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe Workspace do
    before do
      @subject = Workspace::FileReference.new('project.xcodeproj', 'group')
    end

    it 'can be initialized by the XML representation' do
      node = REXML::Element.new("FileRef")
      node.attributes['location'] = "group:project.xcodeproj"
      result = Workspace::FileReference.from_node(node)
      result.should == @subject
    end

    it 'returns the XML representation' do
      result = @subject.to_node
      result.class.should == REXML::Element
      result.to_s.should == "<FileRef location='group:project.xcodeproj'/>"
    end

    it 'can be converted back and forth without loss of information' do
      result = Workspace::FileReference.from_node(@subject.to_node)
      result.should == @subject
    end

    it 'returns the absolute path for group types' do
      result = @subject.absolute_path('/path/to/')
      result.should == "/path/to/project.xcodeproj"
    end

    it 'returns the absolute path for container types' do
      @subject.stubs(:type).returns('container')
      result = @subject.absolute_path('/path/to/')
      result.should == "/path/to/project.xcodeproj"
    end

    it 'returns the absolute path for absolute types' do
      @subject.stubs(:type).returns('absolute')
      result = @subject.absolute_path('/path/to/')
      result.should == File.expand_path(@subject.path)
    end
  end
end
