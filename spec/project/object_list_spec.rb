require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::PBXObjectList" do
    before do
      @project.groups.where(:name => 'Frameworks').files.first.destroy

      @uuid, @attributes = @project.objects_hash.find { |_, attr| attr['isa'] == 'PBXFileReference' }
      @added_uuids = []
      @list = Xcodeproj::Project::PBXObjectList.new(PBXFileReference, @project) do |list|
        list.let(:push) do |new_object|
          @added_uuids << new_object.uuid
        end
        list.let(:uuid_scope) do
          uuid, _ = @project.objects_hash.find { |_, attr| attr['isa'] == 'PBXFileReference' }
          uuid ? [uuid] : []
        end
      end
    end

    it "returns wether or not it's empty" do
      @list.should.not.be.empty
      @project.objects[@uuid].destroy
      @list.should.be.empty
    end

    it "returns the UUIDs to which it limits the scope of the list" do
      @list.uuid_scope.should == [@uuid]
    end

    it "returns the object for the specified UUID, if it's in the scoped uuids list" do
      @list['DOESNOTEXIST'].should == nil
      @list[@project.main_group.uuid].should == nil
      @list[@uuid].attributes.should == @attributes
    end

    it "yields the objects in the scoped uuids list" do
      yielded = []
      @list.each { |o| yielded << o.uuid }
      yielded.should == [@uuid]
    end

    it "adds an instance of the specified class to the objects hash and calls the callback to associate it" do
      file = @list.add(PBXFileReference, 'path' => 'some/path')
      file.should.be.instance_of PBXFileReference
      file.path.should == 'some/path'
      @project.objects[file.uuid].should == file
      @added_uuids.should == [file.uuid]
    end

    it "adds a new instance of the class it represents" do
      file = @list.new('path' => 'some/path')
      file.should.be.instance_of PBXFileReference
      file.path.should == 'some/path'
      @project.objects[file.uuid].should == file
      @added_uuids.should == [file.uuid]
    end

    it "calls the callback to associate the object" do
      file = @project.files.new('path' => 'some/path')
      @list << file
      @added_uuids.should == [file.uuid]
    end

    it "is comparable to another list" do
      @list.should == Xcodeproj::Project::PBXObjectList.new(PBXFileReference, @project) do |list|
        list.let(:uuid_scope) { [@uuid] }
      end
    end

    it "returns the object matching the specified attributes (but only if they have accessors)" do
      @list.where(:path => 'libPods.a').should == @project.objects[@uuid]
      @list.where(:path => 'libPods.a', :source_tree => 'BUILT_PRODUCTS_DIR').should == @project.objects[@uuid]
      @list.where(:path => 'libPods.a', :does_not => 'exist').should == nil
    end

    it "returns an object with the given name" do
      @list.object_named('DOESNOTEXIST').should == nil
      p @project.objects
      @list.object_named('libPods.a').should == @project.objects[@uuid]
    end

    it "forwards a missing method to the represented class, if it exists, which is expected to return a new instance" do
      @list.instance_variable_set(:@represented_class, PBXNativeTarget)
      target = @list.new_static_library(:ios, 'AnotherLib')
      target.should.be.instance_of PBXNativeTarget
      target.product.name.should == 'libAnotherLib.a'
      @project.objects[target.uuid].should == target
      @added_uuids.should == [target.uuid]
    end
  end
end
