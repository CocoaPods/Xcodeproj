require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Workspace do
  describe 'from new' do
    before do
      @pods_project_file_reference = Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
      @project_file_reference = Xcodeproj::Workspace::FileReference.new('App.xcodeproj')
      @workspace = Xcodeproj::Workspace.new(@pods_project_file_reference, @project_file_reference)
    end

    it 'contains the initial projects' do
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('App.xcodeproj')
    end

    it 'accepts new projects' do
      @workspace << 'Framework.xcodeproj'
      proj_ref = Xcodeproj::Workspace::FileReference.new('Framework.xcodeproj')
      @workspace.file_references.should == [@pods_project_file_reference, @project_file_reference, proj_ref]
    end

    it 'should skip duplicate projects' do
      @workspace << 'Framework.xcodeproj'
      @workspace << 'Framework.xcodeproj'
      proj_ref = Xcodeproj::Workspace::FileReference.new('Framework.xcodeproj')
      @workspace.file_references.should == [@pods_project_file_reference, @project_file_reference, proj_ref]
    end

    it 'should skip duplicate projects with messy paths' do
      @workspace << 'OtherDirectory/../Directory/Framework.xcodeproj'
      @workspace << 'Directory/Framework.xcodeproj'
      proj_ref = Xcodeproj::Workspace::FileReference.new('Directory/Framework.xcodeproj')
      @workspace.file_references.should == [@pods_project_file_reference, @project_file_reference, proj_ref]
    end

    it 'accepts new groups' do
      added_group = @workspace.add_group('Test Group')
      added_group.should.not.be.nil
      @workspace.group_references.should.include added_group
    end

    it 'allows file references to be added to groups' do
      file_reference_in_group = Xcodeproj::Workspace::FileReference.new('ProjectInGroup.xcodeproj')
      @workspace.add_group('Another Group') do |_, elem|
        elem.add_element(file_reference_in_group.to_node)
      end
      @workspace.group_references.should.include Xcodeproj::Workspace::GroupReference.new('Another Group')
      @workspace.file_references.should.include file_reference_in_group
    end

    it 'can handle nil for a workspace document' do
      @workspace = Xcodeproj::Workspace.new(nil)
      @workspace.document.should.not.be.nil
    end
  end

  describe 'converted to XML' do
    before do
      pods_project_file_reference = Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
      project_file_reference = Xcodeproj::Workspace::FileReference.new('App&<>\'.xcodeproj')
      @workspace = Xcodeproj::Workspace.new(pods_project_file_reference, project_file_reference)

      file_reference_in_group = Xcodeproj::Workspace::FileReference.new('ProjectInGroup.xcodeproj')
      @workspace.add_group('Another Group') do |_, elem|
        elem.add_element(file_reference_in_group.to_node)
      end

      @doc = REXML::Document.new(@workspace.to_s)
    end

    it 'is the right xml workspace version' do
      @doc.root.attributes['version'].to_s.should == '1.0'
    end

    it 'refers to the projects in xml' do
      @doc.root.get_elements('/Workspace//FileRef').map do |node|
        node.attributes['location']
      end.sort.should == ['group:App&<>\'.xcodeproj', 'group:Pods/Pods.xcodeproj', 'group:ProjectInGroup.xcodeproj']
    end

    it 'formats the XML consistently with Xcode' do
      expected = <<-DOC
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Pods/Pods.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:App&amp;&lt;&gt;&apos;.xcodeproj">
   </FileRef>
   <Group
      location = "container:"
      name = "Another Group">
      <FileRef
         location = "group:ProjectInGroup.xcodeproj">
      </FileRef>
   </Group>
</Workspace>
      DOC
      @workspace.to_s.should == expected
    end
  end

  describe 'built from a workspace file' do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path('libPusher.xcworkspace'))
    end

    it 'contains all of the projects in the workspace' do
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('libPusher.xcodeproj')
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('libPusher-OSX/libPusher-OSX.xcodeproj')
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('ProjectInAGroup.xcodeproj')
    end

    it 'contains the group' do
      @workspace.group_references.should.include Xcodeproj::Workspace::GroupReference.new('Test Group')
    end
  end

  describe 'built from an empty/invalid workspace file' do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace("doesn't exist")
    end

    it 'contains no projects' do
      @workspace.file_references.should.be.empty
    end

    it 'contains no groups' do
      @workspace.group_references.should.be.empty
    end
  end

  describe 'load schemes for all projects from workspace file' do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path('SharedSchemes/SharedSchemes.xcworkspace'))
    end

    it 'returns data type should be hash' do
      @workspace.schemes.should.instance_of Hash
    end

    it 'schemes count should be greater or equal to file_references count' do
      @workspace.schemes.count.should >= @workspace.file_references.count
    end

    it 'contains only test data schemes' do
      @workspace.schemes.keys.sort.should == %w(Pods SharedSchemes SharedSchemesForTest)
    end
  end

  describe 'load schemes for all projects and the workspace from a workspace file' do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path('WorkspaceSchemes/WorkspaceSchemes.xcworkspace'))
    end

    it 'returns data type should be hash' do
      @workspace.schemes.should.instance_of Hash
    end

    it 'schemes count should be greater or equal to file_references count' do
      @workspace.schemes.count.should >= @workspace.file_references.count
    end

    it 'contains only test data schemes' do
      @workspace.schemes.keys.sort.should == %w(
        WorkspaceSchemesApp WorkspaceSchemesFramework WorkspaceSchemesScheme
        project_in_group_type_group project_in_subgroup scheme_in_subgroup_with_location
      )
    end

    it 'schemes hash contain path to a valid project/workspace' do
      @workspace.schemes.values.each do |path|
        File.exist?(path).should == true
      end
    end
  end

  describe 'built from a workspace file with XML entities in a project path' do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("Otto's Remote.xcworkspace"))
    end

    it 'contains all of the projects in the workspace' do
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new("Otto's Remote.xcodeproj")
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
    end
  end
end
