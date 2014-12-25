require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe XCBuildConfiguration do
    before do
      @configuration_list = @project.new(XCConfigurationList)
    end

    it 'by the default the default configuration is not visible' do
      @configuration_list.default_configuration_is_visible.should == '0'
    end

    it 'returns the default configuration name' do
      @configuration_list.default_configuration_name = 'Release'
      @configuration_list.default_configuration_name.should == 'Release'
    end

    it 'returns the configurations' do
      configuration = @project.new(XCBuildConfiguration)
      @configuration_list.build_configurations.to_a.should == []
      @configuration_list.build_configurations << configuration
      @configuration_list.build_configurations.count.should == 1
      @configuration_list.build_configurations.should.include?(configuration)
    end

    it 'returns the build configuration with the given name' do
      configuration = @project.new(XCBuildConfiguration)
      configuration.name = 'Debug'
      @configuration_list.build_configurations << configuration
      @configuration_list['Debug'].name.should == 'Debug'
    end

    it 'returns the build settings of a configuration given its name' do
      settings = { 'GCC_VERSION' => 'com.apple.compilers.llvm.clang.1_0' }
      configuration = @project.new(XCBuildConfiguration)
      configuration.name = 'Debug'
      configuration.build_settings = settings
      @configuration_list.build_configurations << configuration
      @configuration_list.build_settings('Debug').should == settings
    end

    it 'sets a build setting to the given value for all the configurations' do
      %w(Debug Release).each do |name|
        configuration = @project.new(XCBuildConfiguration)
        configuration.name = name
        configuration.build_settings = { 'CLANG_ENABLE_OBJC_ARC' => 'NO' }
        @configuration_list.build_configurations << configuration
      end
      @configuration_list.get_setting('CLANG_ENABLE_OBJC_ARC').should == { 'Debug' => 'NO', 'Release' => 'NO' }
    end

    it 'sets a build setting to the given value for all the configurations' do
      %w(Debug Release).each do |name|
        configuration = @project.new(XCBuildConfiguration)
        configuration.name = name
        configuration.build_settings = { 'CLANG_ENABLE_OBJC_ARC' => 'NO' }
        @configuration_list.build_configurations << configuration
      end

      @configuration_list.set_setting('CLANG_ENABLE_OBJC_ARC', 'YES')
      @configuration_list.get_setting('CLANG_ENABLE_OBJC_ARC').should == { 'Debug' => 'YES', 'Release' => 'YES' }
    end
  end
end
