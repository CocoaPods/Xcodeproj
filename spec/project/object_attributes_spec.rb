require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs

  describe AbstractObjectAttribute do
    before do
      @attrb = AbstractObjectAttribute.new(:simple, :source_tree, PBXFileReference)
    end

    it "returns its type" do
      @attrb.type.should == :simple
    end

    it "returns its name" do
      @attrb.name.should == :source_tree
    end

    it "returns its owner" do
      @attrb.owner.should.equal?(PBXFileReference)
    end

    it "returns its plist name" do
      @attrb.plist_name.should == 'sourceTree'
    end

    it "can store the accepted classes for the value type checking" do
      @attrb.classes = [String]
      @attrb.classes.should == [String]
    end

    it "can store a default value" do
      @attrb.default_value = 'A_ROOT'
      @attrb.default_value.should == 'A_ROOT'
    end

    it "can get its value for a given object" do
      file = @project.new(PBXFileReference)
      file.source_tree = 'A_ROOT'
      @attrb.get_value(file).should == 'A_ROOT'
    end

    it "can set its value for a given object" do
      file = @project.new(PBXFileReference)
      @attrb.set_value(file, 'A_ROOT')
      file.source_tree.should == 'A_ROOT'
    end

    it "can set its default value for a given object" do
      @attrb.default_value = 'SAMPLE_ROOT'
      file = @project.new(PBXFileReference)
      file.source_tree.should != 'SAMPLE_ROOT'
      @attrb.set_default(file)
      file.source_tree.should == 'SAMPLE_ROOT'
    end

    it "can validate a simple value" do
      @attrb.classes = [String]
      lambda { @attrb.validate_value('a string') }.should.not.raise
      lambda { @attrb.validate_value(['array']) }.should.raise
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
