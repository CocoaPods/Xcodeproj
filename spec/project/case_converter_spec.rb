require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe CaseConverter do
    it 'converts a name to the plist format' do
      result = CaseConverter.convert_to_plist(:project_ref)
      result.should == 'ProjectRef'
    end

    it 'converts a name to the plist format starting with a lowercase letter' do
      result = CaseConverter.convert_to_plist(:source_tree, :lower)
      result.should == 'sourceTree'
    end

    it 'handles remoteGlobalIDString' do
      result = CaseConverter.convert_to_plist(:remote_global_id_string, :lower)
      result.should.not == 'remoteGlobalIdString'
      result.should == 'remoteGlobalIDString'
    end

    it 'caches plist names to speed up the conversion' do
      CaseConverter.stubs(:plist_cache).returns({})
      CaseConverter.convert_to_plist(:source_tree, :lower)
      CaseConverter.expects(:camelize).never
      CaseConverter.convert_to_plist(:source_tree, :lower)
    end

    it 'concerts a name to the Ruby symbol' do
      result = CaseConverter.convert_to_ruby('ProjectRef')
      result.should == :project_ref
    end
  end
end
