require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe XCBuildConfiguration do
    before do
      @configuration = @project.new(XCBuildConfiguration)
    end

    describe 'In general' do
      it 'returns its name' do
        @configuration.name = 'Release'
        @configuration.name.should == 'Release'
      end

      it 'returns the empty hash as default build settings' do
        @configuration.build_settings.should == {}
      end

      it 'returns the xcconfig that this configuration is based on' do
        xcconfig = @project.new_file('file.xcconfig')
        @configuration.base_configuration_reference = xcconfig
        @configuration.base_configuration_reference.should.be.not.nil
      end
    end

    #-------------------------------------------------------------------------#

    describe 'AbstractObject Hooks' do
      it 'returns the pretty print representation' do
        @configuration.name = 'Release'
        @configuration.build_settings = { 'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES' }
        xcconfig = @project.new_file('file.xcconfig')
        @configuration.base_configuration_reference = xcconfig

        @configuration.pretty_print.should == {
          'Release' => {
            'Build Settings' => {
              'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES',
            },
            'Base Configuration' => 'file.xcconfig',
          },
        }
      end
    end

    #-------------------------------------------------------------------------#

    describe 'AbstractObject Hooks' do
      it 'can be sorted' do
        @configuration.name = 'Release'
        @configuration.build_settings = { 'KEY_B' => 'B', 'KEY_A' => 'A' }
        @configuration.sort
        @configuration.build_settings.keys.should == %w(KEY_A KEY_B)
      end
    end

    #-------------------------------------------------------------------------#
  end
end
