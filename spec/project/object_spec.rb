require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXObject" do
    describe ", concerning attributes," do
      it "defines accessor methods with the given name, the attributes key is expected to be the camelized version of the name" do
        klass = Class.new(PBXObject) { attribute :product_ref_group }
        object = klass.new(@project, nil, { 'productRefGroup' => 'UUID', 'isa' => 'PBXObject' })
        object.product_ref_group.should == 'UUID'
        object.product_ref_group = 'Another UUID'
        object.product_ref_group.should == 'Another UUID'
        object.attributes['productRefGroup'].should == 'Another UUID'
      end

      it "optionally takes a second parameter which specifies the attributes key" do
        klass = Class.new(PBXObject) { attribute :product_ref_group, :as => :products_group }
        object = klass.new(@project, nil, { 'productRefGroup' => 'UUID', 'isa' => 'PBXObject' })
        object.products_group.should == 'UUID'
        object.products_group = 'Another UUID'
        object.products_group.should == 'Another UUID'
        object.attributes['productRefGroup'].should == 'Another UUID'
      end
    end

    before do
      @object = PBXObject.new(@project, nil, 'name' => 'AnObject')
    end

    it "merges the class name into the attributes" do
      @object.isa.should == 'PBXObject'
      @object.attributes['isa'].should == 'PBXObject'
    end

    it "takes a name" do
      @object.name.should == 'AnObject'
      @object.name = 'AnotherObject'
      @object.name.should == 'AnotherObject'
    end

    it "generates a uuid" do
      @object.uuid.should.be.instance_of String
      @object.uuid.size.should == 24
      @object.uuid.should == @object.uuid
    end

    it "adds the object to the objects hash" do
      @project.objects_hash[@object.uuid].should == @object.attributes
    end
  end
end
