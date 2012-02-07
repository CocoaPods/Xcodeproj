require File.expand_path('../spec_helper', __FILE__)

describe "Xcodeproj::Workspace" do
  before do
    @workspace = Xcodeproj::Workspace.new('Pods/Pods.xcodeproj', 'App.xcodeproj')
  end
  
  it "accepts new projects" do
    @workspace << 'Framework.xcodeproj'
    @workspace.projpaths.should.include 'Framework.xcodeproj'
  end
    
  before do
    @doc = REXML::Document.new(@workspace.to_s)
  end
  
  it "is the right xml workspace version" do
    @doc.root.attributes['version'].to_s.should == "1.0"
  end
  
  it "refers to the projects in xml" do
    @doc.nodesForXPath("/Workspace/FileRef", error:nil).map do |node|
      node.attributeForName("location").stringValue.sub(/^group:/, '')
    end.sort.should == ['App.xcodeproj', 'Pods/Pods.xcodeproj']
  end
end
