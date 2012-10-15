require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXContainerItemProxy do

    before do
      @proxy = @project.new(PBXContainerItemProxy)
    end

    it "returns the container portal" do
      @proxy.container_portal = @project.root_object.uuid
      @proxy.container_portal.should == @project.root_object.uuid
    end

    it "returns the type of the proxy" do
      @proxy.proxy_type = "1"
      @proxy.proxy_type.should == "1"
    end

    it "returns the remote global id string" do
      target = @project.new_target(:static, "Pods", :ios)
      @proxy.remote_global_id_string = target.uuid
      @proxy.remote_global_id_string.should == target.uuid
    end

    it "returns the remote info" do
      @proxy.remote_info = "Pods"
      @proxy.remote_info.should == "Pods"
    end

  end
end

