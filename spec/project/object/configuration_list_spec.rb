require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe XCBuildConfiguration do

    before do
      @list = @project.new(XCConfigurationList)
    end

    it "by the default the default configuration is not visible" do
      @list.default_configuration_is_visible.should == '0'
    end

    it "returns the default configuration name" do
      @list.default_configuration_name = 'Release'
      @list.default_configuration_name.should == 'Release'
    end

    it "returns the configurations" do
      configuration = @project.new(XCBuildConfiguration)
      @list.build_configurations.to_a.should == []
      @list.build_configurations << configuration
      @list.build_configurations.count.should == 1
      @list.build_configurations.should.include?(configuration)
    end

    it "returns the build settings of a configuration given its name" do
      settings = { 'GCC_VERSION' => 'com.apple.compilers.llvm.clang.1_0'}
      configuration = @project.new(XCBuildConfiguration)
      configuration.name = 'Debug'
      configuration.build_settings =  settings
      @list.build_configurations << configuration
      @list.build_settings('Debug').should == settings
    end

  end
end

