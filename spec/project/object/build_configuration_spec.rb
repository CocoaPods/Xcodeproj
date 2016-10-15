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

      describe '#debug?' do
        it 'returns false without build settings' do
          @configuration.should.not.be.debug
        end

        it 'returns true when the preprocessor definitions include DEBUG=1' do
          @configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['Foo', 'DEBUG=1']
          @configuration.should.be.debug
        end

        it 'returns false when the preprocessor definitions include DEBUG=0' do
          @configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['Foo', 'DEBUG=0']
          @configuration.should.not.be.debug
        end
      end

      describe '#type' do
        it 'returns :debug when it is debug' do
          @configuration.expects(:debug?).returns(true)
          @configuration.type.should == :debug
        end

        it 'returns :release when it is not debug' do
          @configuration.expects(:debug?).returns(false)
          @configuration.type.should == :release
        end
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

      it 'can be sorted' do
        @configuration.name = 'Release'
        @configuration.build_settings = { 'KEY_B' => 'B', 'KEY_A' => 'A' }
        @configuration.sort
        @configuration.build_settings.keys.should == %w(KEY_A KEY_B)
      end

      it 'transforms values with multiple values to arrays' do
        @configuration.build_settings = {
          'ALTERNATE_PERMISSIONS_FILES' => 'a $(inherited) \'bc\' "de fg"',
          'ARCHS' => 'a $(inherited) \'bc\' "de fg"',
          'BUILD_VARIANTS' => 'a $(inherited) \'bc\' "de fg"',
          'EXCLUDED_SOURCE_FILE_NAMES' => 'a $(inherited) \'bc\' "de fg"',
          'FRAMEWORK_SEARCH_PATHS' => 'a $(inherited) \'bc\' "de fg"',
          'GCC_PREPROCESSOR_DEFINITIONS' => 'a $(inherited) \'bc\' "de fg"',
          'GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS' => 'a $(inherited) \'bc\' "de fg"',
          'HEADER_SEARCH_PATHS' => 'a $(inherited) \'bc\' "de fg"',
          'INFOPLIST_PREPROCESSOR_DEFINITIONS' => 'a $(inherited) \'bc\' "de fg"',
          'LIBRARY_SEARCH_PATHS' => 'a $(inherited) \'bc\' "de fg"',
          'OTHER_CFLAGS' => 'a $(inherited) \'bc\' "de fg"',
          'OTHER_CPLUSPLUSFLAGS' => 'a $(inherited) \'bc\' "de fg"',
          'OTHER_LDFLAGS' => 'a $(inherited) \'bc\' "de fg"',

          'BLARG_SEARCH_PATHS' => 'a $(inherited) \'bc\' "de fg"',
        }
        @configuration.to_hash.should == {
          'isa' => 'XCBuildConfiguration',
          'buildSettings' => {
            'ALTERNATE_PERMISSIONS_FILES' => ['a', '$(inherited)', 'bc', 'de fg'],
            'ARCHS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'BUILD_VARIANTS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'EXCLUDED_SOURCE_FILE_NAMES' => ['a', '$(inherited)', 'bc', 'de fg'],
            'FRAMEWORK_SEARCH_PATHS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'GCC_PREPROCESSOR_DEFINITIONS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'HEADER_SEARCH_PATHS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'INFOPLIST_PREPROCESSOR_DEFINITIONS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'LIBRARY_SEARCH_PATHS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'OTHER_CFLAGS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'OTHER_CPLUSPLUSFLAGS' => ['a', '$(inherited)', 'bc', 'de fg'],
            'OTHER_LDFLAGS' => ['a', '$(inherited)', 'bc', 'de fg'],

            'BLARG_SEARCH_PATHS' => 'a $(inherited) \'bc\' "de fg"',
          },
        }
      end

      it 'keeps values with a single value as a string' do
        @configuration.build_settings = {
          'ALTERNATE_PERMISSIONS_FILES' => '"abcd"',
          'ARCHS' => '"abcd"',
          'BUILD_VARIANTS' => '"abcd"',
          'EXCLUDED_SOURCE_FILE_NAMES' => '"abcd"',
          'FRAMEWORK_SEARCH_PATHS' => '"abcd"',
          'GCC_PREPROCESSOR_DEFINITIONS' => '"abcd"',
          'GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS' => '"abcd"',
          'HEADER_SEARCH_PATHS' => '"abcd"',
          'INFOPLIST_PREPROCESSOR_DEFINITIONS' => '"abcd"',
          'LIBRARY_SEARCH_PATHS' => '"abcd"',
          'OTHER_CFLAGS' => '"abcd"',
          'OTHER_CPLUSPLUSFLAGS' => '"abcd"',
          'OTHER_LDFLAGS' => '"abcd"',

          'BLARG_SEARCH_PATHS' => '"abcd"',
        }
        @configuration.to_hash.should == {
          'isa' => 'XCBuildConfiguration',
          'buildSettings' => {
            'ALTERNATE_PERMISSIONS_FILES' => '"abcd"',
            'ARCHS' => '"abcd"',
            'BUILD_VARIANTS' => '"abcd"',
            'EXCLUDED_SOURCE_FILE_NAMES' => '"abcd"',
            'FRAMEWORK_SEARCH_PATHS' => '"abcd"',
            'GCC_PREPROCESSOR_DEFINITIONS' => '"abcd"',
            'GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS' => '"abcd"',
            'HEADER_SEARCH_PATHS' => '"abcd"',
            'INFOPLIST_PREPROCESSOR_DEFINITIONS' => '"abcd"',
            'LIBRARY_SEARCH_PATHS' => '"abcd"',
            'OTHER_CFLAGS' => '"abcd"',
            'OTHER_CPLUSPLUSFLAGS' => '"abcd"',
            'OTHER_LDFLAGS' => '"abcd"',

            'BLARG_SEARCH_PATHS' => '"abcd"',
          },
        }
      end
    end

    #-------------------------------------------------------------------------#
  end
end
