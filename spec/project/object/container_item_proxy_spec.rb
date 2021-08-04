require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXContainerItemProxy do
    before do
      @proxy = @project.new(PBXContainerItemProxy)
    end

    it 'returns the container portal' do
      @proxy.container_portal = @project.root_object.uuid
      @proxy.container_portal.should == @project.root_object.uuid
    end

    it 'returns the type of the proxy' do
      @proxy.proxy_type = '1'
      @proxy.proxy_type.should == '1'
    end

    it 'returns the remote global id string' do
      target = @project.new_target(:static, 'Pods', :ios)
      @proxy.remote_global_id_string = target.uuid
      @proxy.remote_global_id_string.should == target.uuid
    end

    it 'returns the remote info' do
      @proxy.remote_info = 'Pods'
      @proxy.remote_info.should == 'Pods'
    end

    describe '#remote?' do
      it 'returns false if the container is for the current project' do
        @proxy.container_portal = @project.root_object.uuid
        @proxy.remote?.should.be.false
      end

      it 'returns true if the container is for a subproject' do
        path = fixture_path('Sample Project/ReferencedProject/ReferencedProject.xcodeproj')
        subproject = Xcodeproj::Project.open(path)
        @project.main_group.new_file(path)
        @proxy.container_portal = subproject.root_object.uuid

        @proxy.remote?.should.be.true
      end
    end

    describe '#proxied_object' do
      before do
        subproject_path = fixture_path('Sample Project/ReferencedProject/ReferencedProject.xcodeproj')
        @subproject = Xcodeproj::Project.open(subproject_path)

        path = fixture_path('Sample Project/ContainsSubproject/ContainsSubproject.xcodeproj')
        @project = Xcodeproj::Project.open(path)
      end

      it 'returns the proxied object if it is contained in the current project' do
        target = @project.targets.find { |t| t.name == 'ContainsSubprojectTests' }
        @proxy = target.dependencies.first.target_proxy
        proxied_object = @proxy.proxied_object
        proxied_object.should == @project.targets.first
      end

      it 'returns the proxied object if it is contained in a subproject' do
        @proxy = @project.targets.first.dependencies.first.target_proxy
        proxied_object = @proxy.proxied_object
        proxied_object.should == @subproject.targets.first
      end
    end
  end
end
