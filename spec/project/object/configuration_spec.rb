require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::XCBuildConfiguration" do
    before do
      @configuration = @project.objects.add(XCBuildConfiguration)
    end

    it "returns the xcconfig that this configuration is based on (baseConfigurationReference)" do
      xcconfig = @project.files.new
      @configuration.base_configuration = xcconfig
      @configuration.base_configuration_reference.should == xcconfig.uuid
    end
  end

  describe "Xcodeproj::Project::Object::XCConfigurationList" do
    before do
      @list = @project.objects.add(XCConfigurationList)
    end

    it "returns the configurations" do
      configuration = @project.objects.add(XCBuildConfiguration)
      @list.build_configurations.to_a.should == []
      @list.build_configurations = [configuration]
      @list.build_configuration_references.should == [configuration.uuid]
    end
  end
end
