require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXTargetDependency do

    before do
      @dep = @project.new(PBXTargetDependency)
    end

    it "returns the target on which this dependency is based" do
      @dep.target = @project.new_target(:static, "Pods", :ios)
      @dep.target.name.should == "Pods"
    end

    it "returns the proxy of the target on which this dependency is based" do
      target = @project.new_target(:static, "Pods", :ios)

      proxy = @project.new(PBXContainerItemProxy)
      proxy.container_portal = @project.root_object
      proxy.remote_info = "Pods"
      proxy.proxy_type = "1"
      proxy.remote_global_id_string = target.uuid

      @dep.targetProxy = proxy
      @dep.targetProxy.remote_info.should == "Pods"
    end


  end
end



