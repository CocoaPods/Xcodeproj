require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Workspace do
  describe "from new" do
    before do
      pods_project_file_reference = Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
      project_file_reference = Xcodeproj::Workspace::FileReference.new('App.xcodeproj')
      @workspace = Xcodeproj::Workspace.new(pods_project_file_reference, project_file_reference)
    end

    it "accepts new projects" do
      @workspace << 'Framework.xcodeproj'
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new('Framework.xcodeproj')
    end
  end

  describe "converted to XML" do
    before do
      pods_project_file_reference = Xcodeproj::Workspace::FileReference.new('Pods/Pods.xcodeproj')
      project_file_reference = Xcodeproj::Workspace::FileReference.new('App.xcodeproj')
      @workspace = Xcodeproj::Workspace.new(pods_project_file_reference, project_file_reference)
      @doc = REXML::Document.new(@workspace.to_s)
    end

    it "is the right xml workspace version" do
      @doc.root.attributes['version'].to_s.should == "1.0"
    end

    it "refers to the projects in xml" do
      @doc.root.get_elements("/Workspace/FileRef").map do |node|
        node.attributes["location"]
      end.sort.should == ['group:App.xcodeproj', 'group:Pods/Pods.xcodeproj']
    end

    it "formats the XML consistently with Xcode" do
      expected = <<-DOC
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Pods/Pods.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:App.xcodeproj">
   </FileRef>
</Workspace>
      DOC
      @workspace.to_s.should == expected
    end
  end

  describe "built from a workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("libPusher.xcworkspace"))
    end

    it "contains all of the projects in the workspace" do
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new("libPusher.xcodeproj")
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new("libPusher-OSX/libPusher-OSX.xcodeproj")
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new("Pods/Pods.xcodeproj")
    end
  end

  describe "built from an empty/invalid workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace("doesn't exist")
    end

    it "contains no projects" do
      @workspace.file_references.should.be.empty
    end
  end

  describe "load schemes for all projects from workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("SharedSchemes/SharedSchemes.xcworkspace"))
    end

    it "returns data type should be hash" do
      @workspace.schemes.should.instance_of Hash
    end

    it "schemes count should be greater or equal to file_references count" do
      @workspace.schemes.count.should >= @workspace.file_references.count
    end

    it "contains only test data schemes" do
      @workspace.schemes.keys.sort.should == ['Pods', 'SharedSchemes', 'SharedSchemesForTest']
    end
  end

  describe "built from a workspace file with XML entities in a project path" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("Otto's Remote.xcworkspace"))
    end

    it "contains all of the projects in the workspace" do
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new("Otto's Remote.xcodeproj")
      @workspace.file_references.should.include Xcodeproj::Workspace::FileReference.new("Pods/Pods.xcodeproj")
    end
  end
end
