require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXReferenceProxy do
    before do
      @ref = @project.new(PBXReferenceProxy)
    end

    it "returns whether it is a proxy" do
      @ref.proxy?.should == true
    end
  end
end
