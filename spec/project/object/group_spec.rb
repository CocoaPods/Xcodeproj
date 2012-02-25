require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXGroup" do
    before do
      @group = @project.groups.new('name' => 'Parent')
      @group.files.new('path' => 'Abracadabra.h')
      @group.files.new('path' => 'Banana.h')
      @group.groups.new('name' => 'ZappMachine')
      @group.files.new('path' => 'Abracadabra.m')
      @group.files.new('path' => 'Banana.m')
    end

    it "returns its name" do
      @group.name.should == 'Parent'
    end

    it "returns the basename of the path as its name" do
      @project.groups.new('path' => 'some/dir').name.should == 'dir'
    end

    it "returns that it's the main group if it is" do
      @project.groups.new.name.should == nil
      @project.main_group.name.should == 'Main Group'
    end

    it "returns a list of files and groups" do
      @group.children.map(&:name).sort.should == %w{ Abracadabra.h Abracadabra.m Banana.h Banana.m ZappMachine }
    end

    it "adds the UUID of the added object to the list of child UUIDS" do
      file = @project.files.new('path' => 'File')
      @group << file
      @group.childReferences.last.should == file.uuid

      group = @project.groups.new
      @group << group
      @group.childReferences.last.should == group.uuid
    end

    it "maintains the order of the assigned children" do
      @group.children = @group.children.sort_by(&:name)
      @group.children.map(&:name).should == %w{ Abracadabra.h Abracadabra.m Banana.h Banana.m ZappMachine }
    end
  end
end

