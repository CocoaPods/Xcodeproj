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

    it 'cleans messy file paths' do
      Workspace::FileReference.new('project.xcodeproj').path.should == 'project.xcodeproj'
      Workspace::FileReference.new('Directory1/directory_2/project.xcodeproj').path.should == 'Directory1/directory_2/project.xcodeproj'
      Workspace::FileReference.new('D1/D2/../../D3/../Directory/project.xcodeproj').path.should == 'Directory/project.xcodeproj'
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

    it 'returns the absolute path for self types' do
      @file.stubs(:type).returns('self')
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

    it 'prepends a parent group path, if it exists, to a path' do
      fileref_node = REXML::Element.new('FileRef')
      fileref_node.attributes['location'] = 'group:fileref_subdir/fileref'

      group_node = REXML::Element.new('Group')
      group_node.attributes['location'] = 'container:dir1/dir2'
      group_node.attributes['name'] = 'The Group Name'
      group_node.add_element(fileref_node)

      fileref = Workspace::FileReference.from_node(fileref_node)
      fileref.path.to_s.should == 'dir1/dir2/fileref_subdir/fileref'
    end

    it 'does not prepend a parent group path to non-group type file references' do
      fileref_node = REXML::Element.new('FileRef')
      fileref_node.attributes['location'] = 'container:fileref_subdir/fileref'

      group_node = REXML::Element.new('Group')
      group_node.attributes['location'] = 'container:dir1/dir2'
      group_node.attributes['name'] = 'The Group Name'
      group_node.add_element(fileref_node)

      fileref = Workspace::FileReference.from_node(fileref_node)
      fileref.path.to_s.should == 'fileref_subdir/fileref'
    end
  end
end
