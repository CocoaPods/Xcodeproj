require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::Association::Reflection" do
    before do
      @reflection = Association::Reflection.new(:has_many, :children, :class => PBXFileReference)
    end

    it "returns the class of the associated object(s)" do
      @reflection.klass.should == PBXFileReference
    end

    it "returns the association type" do
      @reflection.type.should == :has_many
    end

    it "returns the association name as a string" do
      @reflection.name.should == 'children'
    end

    # TODO add a spec which tests AbstractPBXObject#attribute to handle case properly
    #it "properly handles case in the reflection name" do
      #reflection = AbstractPBXObject::AssociationReflection.new(:has_one, :build_configuration_list, :class => PBXFileReference)
      #reflection.uuid_method_name.should == 'build_configuration_list_reference'
    #end

    #it "returns the association reflection of the other side of the current association" do
      
    #end
  end

  describe "Xcodeproj::Project::Object::Association::Reflection, with type `:has_many`" do
    before do
      @reflection = Association::Reflection.new(:has_many, :children, :class => PBXFileReference)
    end

    it "returns the UUIDs attribute name" do
      @reflection.attribute_name.should == :children
      @reflection.options[:uuids] = :build_files
      @reflection.attribute_name.should == :build_files
    end

    it "returns the names of the UUIDs attribute getter and setter methods" do
      @reflection.attribute_getter.should == :child_references
      @reflection.attribute_setter.should == :child_references=
      @reflection.options[:uuids] = :build_files
      @reflection.attribute_getter.should == :build_files
      @reflection.attribute_setter.should == :build_files=
    end

    it "returns the getter method name of the association, on which the UUIDs attribute name has no influence" do
      @reflection.getter.should == :children
      @reflection.options[:uuids] = :build_files
      @reflection.getter.should == :children
    end

    it "returns the setter method name of the asociation, on which the UUIDs attribute name has no influence" do
      @reflection.setter.should == :children=
      @reflection.options[:uuids] = :build_files
      @reflection.setter.should == :children=
    end

    it "returns a new HasMany association for the given owner instance" do
      owner = Object.new
      association = @reflection.association_for(owner)
      association.should.be.instance_of Association::HasMany
      association.owner.should == owner
      association.reflection.should == @reflection
    end
  end

  describe "Xcodeproj::Project::Object::Association::Reflection, with type `:has_one`" do
    before do
      @reflection = Association::Reflection.new(:has_one, :build_configuration_list, :class => PBXFileReference)
    end

    it "returns the UUID attribute name" do
      @reflection.attribute_name.should == :build_configuration_list
      @reflection.options[:uuid] = :build_file
      @reflection.attribute_name.should == :build_file
    end

    it "returns the names of the UUID attribute getter and setter methods" do
      @reflection.attribute_getter.should == :build_configuration_list_reference
      @reflection.attribute_setter.should == :build_configuration_list_reference=
      @reflection.options[:uuid] = :build_file
      @reflection.attribute_getter.should == :build_file
      @reflection.attribute_setter.should == :build_file=
    end

    it "returns the getter method name of the association, on which the UUID attribute name has no influence" do
      @reflection.getter.should == :build_configuration_list
      @reflection.options[:uuid] = :build_file
      @reflection.getter.should == :build_configuration_list
    end

    it "returns the setter method name of the asociation, on which the UUID attribute name has no influence" do
      @reflection.setter.should == :build_configuration_list=
      @reflection.options[:uuid] = :build_file
      @reflection.setter.should == :build_configuration_list=
    end

    it "returns a new HasOne association for the given owner instance" do
      owner = Object.new
      association = @reflection.association_for(owner)
      association.should.be.instance_of Association::HasOne
      association.owner.should == owner
      association.reflection.should == @reflection
    end
  end
end
