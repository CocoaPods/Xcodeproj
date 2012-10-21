require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe XCBuildConfiguration do

    before do
      @configuration = @project.new(XCBuildConfiguration)
    end

    it "returns its name" do
      @configuration.name = "a_name"
      @configuration.name.should == "a_name"
    end

    it "returns the empty hash as default build settings" do
      @configuration.build_settings.should == {}
    end

    it "returns the xcconfig that this configuration is based on" do
      xcconfig = @project.new_file('file.xcconfig')
      @configuration.base_configuration_reference = xcconfig
      @configuration.base_configuration_reference.should.be.not.nil
    end

  end
end

