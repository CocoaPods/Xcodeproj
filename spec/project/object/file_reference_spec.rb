require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXFileReference" do
    it "sets a default file type" do
      framework, library, xcconfig = %w[framework a xcconfig].map { |n| @project.files.new('path' => "Rockin.#{n}") }
      framework.lastKnownFileType.should == 'wrapper.framework'
      framework.explicitFileType.should == nil
      library.lastKnownFileType.should == nil
      library.explicitFileType.should == 'archive.ar'
      xcconfig.lastKnownFileType.should == 'text.xcconfig'
      xcconfig.explicitFileType.should == nil
    end
    
    it "doesn't set a file type when overridden" do
      fakework = @project.files.new('path' => 'Sup.framework', 'lastKnownFileType' => 'fish')
      fakework.lastKnownFileType.should == 'fish'
      makework = @project.files.new('path' => 'n2m.framework', 'explicitFileType' => 'tree')
      makework.lastKnownFileType.should == nil
    end
    
    before do
      @file = @project.files.new('path' => 'some/file.m')
    end

    it "is automatically added to the main group" do
      @file.group.should == @project.main_group
    end

    it "is removed from the original group when added to another group" do
      group = @project.groups.new
      group.children << @file
      @file.group.should == group
      @project.main_group.children.should.not.include @file
    end
  end
end
