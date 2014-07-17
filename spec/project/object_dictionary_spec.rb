require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ObjectDictionary do
    before do
      attribute = AbstractObjectAttribute.new(:references_by_keys, :project_references, PBXProject)
      attribute.classes = [PBXFileReference, PBXGroup]
      @dictionary = Xcodeproj::Project::ObjectDictionary.new(attribute, @project.root_object)
      @dictionary['projectRef']   =  @project.new(PBXFileReference)
      @dictionary['productGroup'] =  @project.new(PBXGroup)
    end

    it "returns the attribute that generated the dictionary" do
      @dictionary.attribute.name.should == :project_references
    end

    it "return the owner of the dictionary" do
      @dictionary.owner.should == @project.root_object
    end

    it "returns the plist representation of the dictionary" do
      project_ref_uuid = @dictionary['projectRef'].uuid
      product_group_uuid = @dictionary['productGroup'].uuid
      @dictionary.to_hash.should == {
        'projectRef' => project_ref_uuid,
        'productGroup' => product_group_uuid,
      }
    end

    it "returns the to tree hash representation of the dictionary" do
      @dictionary['projectRef'].name = "A product"
      @dictionary['projectRef'].path = "A path"
      @dictionary['productGroup'].name = "Products"
      @dictionary.to_tree_hash.should == {
        "projectRef"=>{
          "displayName"=>"A product",
          "isa"=>"PBXFileReference",
          "name"=>"A product",
          "path"=>"A path",
          "sourceTree"=>"SOURCE_ROOT",
          "includeInIndex"=>"1"
        },
        "productGroup"=>{
          "displayName"=>"Products",
          "isa"=>"PBXGroup",
          "sourceTree"=>"<group>",
          "name"=>"Products",
          "children"=>[]
        }
      }
    end

    it "informs an object that is has been added to the dictionary" do
      f = @dictionary['projectRef']
      f.referrers.should.include?(@project.root_object)
    end

    it "informs an object that the referenced stopped if its associated key is deleted" do
      f = @dictionary['projectRef']
      f.referrers.count.should == 1
      f.referrers.should.include?(@project.root_object)
      @dictionary.delete('projectRef')
      f.referrers.count.should == 0
    end

    it "informs an object that the referenced stopped if its associated key is set to nil" do
      f = @dictionary['projectRef']
      f.referrers.count.should == 1
      f.referrers.should.include?(@project.root_object)
      @dictionary['projectRef'] = nil
      f.referrers.count.should == 0
    end
  end
end

