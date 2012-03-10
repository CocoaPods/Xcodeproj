require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::AbstractPBXObject::AssociationReflection" do
    before do
      @reflection = AbstractPBXObject::AssociationReflection.new(:children, :class => PBXFileReference)
    end

    it "returns the class of the associated object(s)" do
      @reflection.klass.should == PBXFileReference
    end

    it "returns the association name as a string" do
      @reflection.name.should == 'children'
    end

    it "returns the name in singular and plural form" do
      @reflection.singular_name.should == 'child'
      @reflection.plural_name.should == 'children'
    end

    it "returns the getter and setter names in singular and plural form" do
      @reflection.singular_getter.should == 'child'
      @reflection.singular_setter.should == 'child='
      @reflection.plural_getter.should == 'children'
      @reflection.plural_setter.should == 'children='
    end

    it "returns the uuid attribute name in singular" do
      @reflection.uuid_method_name.should == 'child_reference'
    end

    it "returns the uuid getter and setter names in singular and plural form" do
      @reflection.uuid_getter.should == 'child_reference'
      @reflection.uuid_setter.should == 'child_reference='
      @reflection.uuids_getter.should == 'child_references'
      @reflection.uuids_setter.should == 'child_references='
    end

    # TODO add a spec which tests AbstractPBXObject#attribute to handle case properly
    it "properly handles case in the reflection name" do
      reflection = AbstractPBXObject::AssociationReflection.new(:build_configuration_list, :class => PBXFileReference)
      reflection.uuid_method_name.should == 'build_configuration_list_reference'
    end

    #it "returns the association reflection of the other side of the current association" do
      
    #end
  end
end
