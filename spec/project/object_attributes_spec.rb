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


    it "returns its value for a given object" do
      file = @project.new(PBXFileReference)
      file.source_tree = 'A_ROOT'
      @attribute.get_value(file).should == 'A_ROOT'
    end

    it "sets its value for a given object" do
      file = @project.new(PBXFileReference)
      @attribute.set_value(file, 'A_ROOT')
      file.source_tree.should == 'A_ROOT'
    end

    it "sets its default value for a given object" do
      @attribute.default_value = 'SAMPLE_ROOT'
      file = @project.new(PBXFileReference)
      file.source_tree.should.not == 'SAMPLE_ROOT'
      @attribute.set_default(file)
      file.source_tree.should == 'SAMPLE_ROOT'
    end

    it "validates a simple value" do
      @attribute.classes = [String]
      lambda { @attribute.validate_value('a string') }.should.not.raise
      lambda { @attribute.validate_value(['array']) }.should.raise
    end

    it "validates an xcodeproj object ISA" do
      attrb = AbstractObjectAttribute.new(:to_many, :children, PBXGroup)
      attrb.classes = [PBXFileReference, PBXGroup]
      file = @project.new(PBXFileReference)
      target = @project.new(PBXNativeTarget)
      lambda { attrb.validate_value(file) }.should.not.raise
      lambda { attrb.validate_value(target) }.should.raise
    end


    describe "references by keys attributes" do
      before do
        @attribute = AbstractObjectAttribute.new(:references_by_keys, :project_references, PBXProject)
        @attribute.classes = [PBXFileReference, PBXGroup]
        @attribute.classes_by_key = {
          :project_ref   => PBXFileReference,
          :product_group => PBXGroup
        }
      end

      it "validates the key of an attribute which stores" do
        file = @project.new(PBXFileReference)
        should.raise do
          @attribute.validate_value_for_key(file, :not_allowed)
        end.message.should.include?('unsupported key')
      end

      it "validates the ISA of the value" do
        file = @project.new(PBXFileReference)
        should.raise do
          @attribute.validate_value_for_key(file, :product_group)
        end.message.should.include?('Type checking error')
      end

      it "accepts a value" do
        file = @project.new(PBXFileReference)
        should.not.raise do
          @attribute.validate_value_for_key(file, :project_ref)
        end
      end
    end
  end
end
