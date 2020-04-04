require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXTargetDependency do
    before do
      @target_dependency = @project.new(PBXTargetDependency)
    end

    it 'may have a name' do
      @target_dependency.name.should.nil?
      @target_dependency.name = "This target's dependency"
      @target_dependency.name.should == "This target's dependency"
    end

    it 'returns the target on which this dependency is based' do
      @target_dependency.target = @project.new_target(:static, 'Pods', :ios)
      @target_dependency.target.name.should == 'Pods'
    end

    it 'returns the proxy of the target on which this dependency is based' do
      target = @project.new_target(:static, 'Pods', :ios)

      proxy = @project.new(PBXContainerItemProxy)
      proxy.container_portal = @project.root_object.uuid
      proxy.remote_info = 'Pods'
      proxy.proxy_type = '1'
      proxy.remote_global_id_string = target.uuid

      @target_dependency.target_proxy = proxy
      @target_dependency.target_proxy.remote_info.should == 'Pods'
    end

    # This is a contrived example of two targets depending on each other, which
    # would lead to an endless sort. It is unlikely that a target would ever
    # depend on itself, as in this example, though.
    it 'does not sort recursively, which would case stack level too deep errors' do
      target = @project.new_target(:static, 'Pods', :ios)
      @target_dependency.target = target
      target.dependencies << @target_dependency
      lambda { @target_dependency.sort_recursively }.should.not.raise
    end

    it 'tree hash does not contain target' do
      target = @project.new_target(:static, 'Pods', :ios)
      @target_dependency.target = target
      target.dependencies << @target_dependency

      proxy = @project.new(PBXContainerItemProxy)
      proxy.container_portal = @project.root_object.uuid
      proxy.remote_info = 'Pods'
      proxy.proxy_type = '1'
      proxy.remote_global_id_string = target.uuid
      @target_dependency.target_proxy = proxy

      @target_dependency.to_tree_hash.should == {
        'displayName' => 'Pods',
        'isa' => 'PBXTargetDependency',
        'targetProxy' => {
          'displayName' => 'ContainerItemProxy',
          'isa' => 'PBXContainerItemProxy',
          'containerPortal' => @project.root_object.uuid,
          'proxyType' => '1',
          'remoteGlobalIDString' => target.uuid,
          'remoteInfo' => 'Pods',
        },
      }
    end

    #----------------------------------------#

    describe '#display_name' do
      it 'returns the name if set' do
        @target_dependency.name = 'Pods'
        @target_dependency.display_name.should == 'Pods'
      end

      it 'returns the name if needed' do
        @target_dependency.target = @project.new_target(:static, 'Pods', :ios)
        @target_dependency.display_name.should == 'Pods'
      end

      it 'returns the remote info if needed' do
        proxy = @project.new(PBXContainerItemProxy)
        proxy.remote_info = 'Pods'
        @target_dependency.target_proxy = proxy
        @target_dependency.display_name.should == 'Pods'
      end
    end

    #----------------------------------------#

    describe '#native_target_uuid' do
      it "returns the target_proxy's remote_global_uuid_string" do
        target = @project.new_target(:static, 'Pods', :ios)

        proxy = @project.new(PBXContainerItemProxy)
        proxy.container_portal = @project.root_object.uuid
        proxy.remote_info = 'Pods'
        proxy.proxy_type = '1'
        proxy.remote_global_id_string = target.uuid

        @target_dependency.target_proxy = proxy
        @target_dependency.target_proxy.remote_global_id_string.nil?.should == false
        @target_dependency.native_target_uuid.should == @target_dependency.target_proxy.remote_global_id_string
      end

      it "returns the target's uuid" do
        target = @project.new_target(:static, 'Pods', :ios)
        @target_dependency.target = target
        @target_dependency.target.uuid.nil?.should == false
        @target_dependency.native_target_uuid.should == @target_dependency.target.uuid
      end

      it "raises if target and target_proxy aren't set" do
        @target_dependency.name = 'TargetName'
        @target_dependency.target.nil?.should == true
        @target_dependency.target_proxy.nil?.should == true
        should.raise do
          @target_dependency.native_target_uuid
        end.message.should.include "Expected target or target_proxy, from which to fetch a uuid for target 'TargetName'." \
          "Find and clear the PBXTargetDependency entry with uuid '#{@target_dependency.uuid}' in your .xcodeproj."
      end
    end
  end
end
