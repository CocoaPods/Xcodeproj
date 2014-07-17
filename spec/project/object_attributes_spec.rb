require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs

  describe AbstractObjectAttribute do
    before do
      @attribute = AbstractObjectAttribute.new(:simple, :source_tree, PBXFileReference)
    end

    it "returns its type" do
      @attribute.type.should == :simple
    end

    it "returns its name" do
      @attribute.name.should == :source_tree
    end

    it "returns its owner" do
      @attribute.owner.should.equal?(PBXFileReference)
    end

    it "returns its plist name" do
      @attribute.plist_name.should == 'sourceTree'
    end

    it "caches the plist names" do
      AbstractObjectAttribute.stubs(:plist_name_store).returns({})
      String.any_instance.expects(:camelize).returns('sourceTree')
      @attribute.plist_name
      String.any_instance.expects(:camelize).never
      @attribute.plist_name.should == 'sourceTree'
    end

    it "can store the accepted classes for the value type checking" do
      @attribute.classes = [String]
      @attribute.classes.should == [String]
    end

    it "can store a default value" do
      @attribute.default_value = 'A_ROOT'
      @attribute.default_value.should == 'A_ROOT'
    end

    it "can get its value for a given object" do
      file = @project.new(PBXFileReference)
      file.source_tree = 'A_ROOT'
      @attribute.get_value(file).should == 'A_ROOT'
    end

    it "can set its value for a given object" do
      file = @project.new(PBXFileReference)
      @attribute.set_value(file, 'A_ROOT')
      file.source_tree.should == 'A_ROOT'
    end

    it "can set its default value for a given object" do
      @attribute.default_value = 'SAMPLE_ROOT'
      file = @project.new(PBXFileReference)
      file.source_tree.should.not == 'SAMPLE_ROOT'
      @attribute.set_default(file)
      file.source_tree.should == 'SAMPLE_ROOT'
    end

    it "can validate a simple value" do
      @attribute.classes = [String]
      lambda { @attribute.validate_value('a string') }.should.not.raise
      lambda { @attribute.validate_value(['array']) }.should.raise
    end

    it "can validate an xcodeproj object isa" do
      attrb = AbstractObjectAttribute.new(:to_many, :children, PBXGroup)
      attrb.classes = [PBXFileReference, PBXGroup]
      file = @project.new(PBXFileReference)
      target = @project.new(PBXNativeTarget)
      lambda { attrb.validate_value(file) }.should.not.raise
      lambda { attrb.validate_value(target) }.should.raise
    end
  end
end
