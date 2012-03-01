require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXObject::AssociationReflection" do
    before do
      @reflection = PBXObject::AssociationReflection.new(:children, :class => PBXFileReference)
    end

    it "returns the association name as a string" do
      @reflection.name.should == 'children'
    end
  end
end
