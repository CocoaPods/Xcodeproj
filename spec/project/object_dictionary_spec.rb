require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ObjectDictionary do
    before do
      attrb = AbstractObjectAttribute.new(:references_by_keys, :project_references, PBXProject)
      attrb.classes = [PBXFileReference, PBXGroup]
      @dict = Xcodeproj::Project::ObjectDictionary.new(attrb, @project.root_object)
      @dict['projectRef']   =  @project.new(PBXFileReference)
      @dict['productGroup'] =  @project.new(PBXGroup)
    end

    it "returns the attribute that generated the dictionary" do
      @dict.attribute.name.should == :project_references
    end

    it "return the owner of the dictionary" do
      @dict.owner.should == @project.root_object
    end

    it "returns the plist representation of the dictionary" do
      project_ref_uuid = @dict['projectRef'].uuid
      product_group_uuid = @dict['productGroup'].uuid
      @dict.to_plist.should == {
        'projectRef' => project_ref_uuid,
        'productGroup' => product_group_uuid,
      }
    end

    it "returns the to tree hash representation of the dictionary" do
      @dict['projectRef'].name = "A product"
      @dict['projectRef'].path = "A path"
      @dict['productGroup'].name = "Products"
      @dict.to_tree_hash.should == {
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
      f = @dict['projectRef']
      f.referrers.should.include?(@project.root_object)
    end

    it "informs an object that the referenced stopped if its associated key is deleted" do
      f = @dict['projectRef']
      f.referrers.count.should == 1
      f.referrers.should.include?(@project.root_object)
      @dict.delete('projectRef')
      f.referrers.count.should == 0
    end

    it "informs an object that the referenced stopped if its associated key is set to nil" do
      f = @dict['projectRef']
      f.referrers.count.should == 1
      f.referrers.should.include?(@project.root_object)
      @dict['projectRef'] = nil
      f.referrers.count.should == 0
    end
  end
end

