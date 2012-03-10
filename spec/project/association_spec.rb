require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::Association::HasMany" do
    before do
      @owner       = @project.groups.new
      @reflection  = Association::Reflection.new(:has_many, :children, :class => PBXFileReference)
      @association = @reflection.association_for(@owner)
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
      @association = Association::HasMany.new(@owner, @reflection) do |o|
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

  describe "An inverse Xcodeproj::Project::Object::Association::HasMany association" do
    before do
      @owner       = @project.files.new('path' => 'some/path')
      @reflection  = Association::Reflection.new(:has_many, :build_files, :inverse_of => :file)
      @association = @reflection.association_for(@owner)
    end

    it "returns the associated objects by finding the ones that have a has_one association to the owner" do
      @association.get.should == []
      build_phase = @project.targets.first.source_build_phases.first
      objects = Array.new(2) { |i| o = build_phase.files.new; o.file = @owner; o }
      # The inverse version traverses the objects hash, so order can't be preserved.
      @association.get.sort_by(&:uuid).should == objects.sort_by(&:uuid)
    end
  end

  describe "Xcodeproj::Project::Object::Association::HasOne" do
    before do
      @owner       = @project.targets.first
      @reflection  = Association::Reflection.new(:has_one, :build_configuration_list, {})
      @association = @reflection.association_for(@owner)
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

  describe "An inverse Xcodeproj::Project::Object::Association::HasOne association" do
    before do
      @owner       = @project.files.new('path' => 'some/path')
      @reflection  = Association::Reflection.new(:has_one, :group, :inverse_of => :children)
      @association = @reflection.association_for(@owner)
    end

    it "returns the associated object by finding the one that has a has_many association which includes the owner" do
      @owner.group.should == @project.main_group
      object = @project.groups.new
      object << @owner
      @owner.group.should == object
      @project.main_group.children.should.not.include @owner
    end
  end
end
