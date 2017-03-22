require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXReferenceProxy do
    before do
      @proxy = @project.new(PBXReferenceProxy)
    end

    it 'returns whether it is a proxy' do
      @proxy.proxy?.should == true
    end

    it 'returns default display_name if path or name are not set' do
      @proxy.display_name.should == 'ReferenceProxy'
    end

    it 'returns name for display_name if name is set' do
      @proxy.name = 'NiceProxy'
      @proxy.path = 'Path/To/Proxy'
      @proxy.display_name.should == 'NiceProxy'
    end

    it 'returns path for display_name if path is set and name is not set' do
      @proxy.path = 'Path/To/Proxy'
      @proxy.display_name.should == 'Path/To/Proxy'
    end
  end
end
