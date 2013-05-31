require File.expand_path('../spec_helper', __FILE__)

describe "Xcodeproj::Workspace" do
  describe "from new" do
    before do
      @workspace = Xcodeproj::Workspace.new('Pods/Pods.xcodeproj', 'App.xcodeproj')
    end

    it "accepts new projects" do
      @workspace << 'Framework.xcodeproj'
      @workspace.projpaths.should.include 'Framework.xcodeproj'
    end
  end

  describe "converted to XML" do
    before do
      @workspace = Xcodeproj::Workspace.new('Pods/Pods.xcodeproj', 'App.xcodeproj')
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
  end

  describe "built from a workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("libPusher.xcworkspace"))
    end

    it "contains all of the projects in the workspace" do
      @workspace.projpaths.should.include "libPusher.xcodeproj"
      @workspace.projpaths.should.include "libPusher-OSX/libPusher-OSX.xcodeproj"
      @workspace.projpaths.should.include "Pods/Pods.xcodeproj"
    end
  end

  describe "built from an empty/invalid workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace("doesn't exist")
    end

    it "contains no projects" do
      @workspace.projpaths.should.be.empty
    end
  end
  
  describe "load schemes for all projects from workspace file" do
    before do
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(fixture_path("SharedSchemes/SharedSchemes.xcworkspace"))
    end
    
    it "returns data type should be hash" do
      @workspace.schemes.should.instance_of Hash
    end
    
    it "schemes count should be greater or equal to projpaths count" do
      @workspace.schemes.count.should >= @workspace.projpaths.count
    end
    
    it "contains only test data schemes" do
      @workspace.schemes.keys.sort.should == ['Pods', 'SharedSchemes', 'SharedSchemesForTest']
    end
  end
end
