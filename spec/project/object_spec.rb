require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXObject" do
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
