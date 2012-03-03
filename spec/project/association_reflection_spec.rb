require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXObject::AssociationReflection" do
    before do
      @reflection = PBXObject::AssociationReflection.new(:children, :class => PBXFileReference)
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
      @reflection.uuid_method_name.should == 'childReference'
    end

    it "returns the uuid getter and setter names in singular and plural form" do
      @reflection.uuid_getter.should == 'childReference'
      @reflection.uuid_setter.should == 'childReference='
      @reflection.uuids_getter.should == 'childReferences'
      @reflection.uuids_setter.should == 'childReferences='
    end
  end
end
