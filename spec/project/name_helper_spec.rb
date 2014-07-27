require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe NameHelper do

    it "converts a name to the plist format" do
      result = NameHelper.convert_to_plist(:project_ref)
      result.should == 'ProjectRef'
    end

    it "converts a name to the plist format starting with a lowercase letter" do
      result = NameHelper.convert_to_plist(:source_tree, :lower)
      result.should == 'sourceTree'
    end

    it "handles remoteGlobalIDString" do
      result = NameHelper.convert_to_plist(:remote_global_id_string, :lower)
      result.should.not == 'remoteGlobalIdString'
      result.should == 'remoteGlobalIDString'
    end

    it "caches plist names to speed up the conversion" do
      AbstractObjectAttribute.stubs(:plist_cache).returns({})
      NameHelper.convert_to_plist(:source_tree, :lower)
      String.any_instance.expects(:camelize).never
      NameHelper.convert_to_plist(:source_tree, :lower)
    end

    it "concerts a name to the Ruby symbol" do
      result = NameHelper.convert_to_ruby('ProjectRef')
      result.should == :project_ref
    end
  end
end
