require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::AbstractPBXObject::Association::HasMany" do
    before do
      @owner      = @project.groups.new
      @reflection  = AbstractPBXObject::AssociationReflection.new(:children, :class => PBXFileReference)
      @association = AbstractPBXObject::Association::HasMany.new(@owner, @reflection)
    end

    it "returns the owner of the associated objects and the reflection" do
      @association.owner.should == @owner
      @association.reflection.should == @reflection
    end

    it "returns a PBXObjectList" do
      @association.get.should.be.instance_of Xcodeproj::Project::PBXObjectList
    end

    it "returns the objects in the associated list" do
      @association.get.should == []
      objects = Array.new(2) { |i| @owner.files.new('path' => "some/path/to/file/#{i}") }
      @association.get.should == objects
    end

    it "uses the passed block, in the context of the owner, whenever an object gets added to the list" do
      yielded_scope  = nil
      yielded_object = nil
      @association = AbstractPBXObject::Association::HasMany.new(@owner, @reflection) do |o|
        yielded_scope  = self
        yielded_object = o
      end
      object = @owner.files.new('path' => 'some/path')
      @association.get << object

      yielded_scope.should == @owner
      yielded_object.should == object
      @association.get.should == [object]
    end

    it "assigns the UUIDs, of the specified objects, to the owner as the new list of associated objects" do
      objects = Array.new(2) { |i| @project.main_group.files.new('path' => "some/path/to/file/#{i}") }
      @association.set(objects)
      @owner.attributes['children'].should == objects.map(&:uuid)
    end
  end

  describe "Xcodeproj::Project::Object::AbstractPBXObject::Associations::HasOne" do
    before do
      @owner       = @project.targets.first
      @reflection  = AbstractPBXObject::AssociationReflection.new(:build_configuration_list, {})
      @association = AbstractPBXObject::Association::HasOne.new(@owner, @reflection)
    end

    it "returns the owner of the associated objects and the reflection" do
      @association.owner.should == @owner
      @association.reflection.should == @reflection
    end

    it "returns the associated object" do
      @association.get.should.not == nil
      @association.get.should == @project.objects[@owner.attributes['buildConfigurationList']]
    end

    it "assigns the UUID, of the specified object, to the ower as the new associated object" do
      object = @project.objects.add(XCConfigurationList)
      @association.set(object)
      @owner.attributes['buildConfigurationList'].should == object.uuid
    end
  end
end
