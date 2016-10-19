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
          'ALTERNATE_PERMISSIONS_FILES' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'ARCHS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'BUILD_VARIANTS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'EXCLUDED_SOURCE_FILE_NAMES' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'FRAMEWORK_SEARCH_PATHS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'GCC_PREPROCESSOR_DEFINITIONS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'HEADER_SEARCH_PATHS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'INFOPLIST_PREPROCESSOR_DEFINITIONS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'LIBRARY_SEARCH_PATHS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'OTHER_CFLAGS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'OTHER_CPLUSPLUSFLAGS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
          'OTHER_LDFLAGS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',

          'BLARG_SEARCH_PATHS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
        }
        @configuration.to_hash.should == {
          'isa' => 'XCBuildConfiguration',
          'buildSettings' => {
            'ALTERNATE_PERMISSIONS_FILES' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'ARCHS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'BUILD_VARIANTS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'EXCLUDED_SOURCE_FILE_NAMES' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'FRAMEWORK_SEARCH_PATHS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'GCC_PREPROCESSOR_DEFINITIONS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'HEADER_SEARCH_PATHS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'INFOPLIST_PREPROCESSOR_DEFINITIONS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'LIBRARY_SEARCH_PATHS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'OTHER_CFLAGS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'OTHER_CPLUSPLUSFLAGS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],
            'OTHER_LDFLAGS' => ['foo', '$(inherited)', '"YYYYY BOO"', 'h"g"', '\\"ab', 'c\\"', 'foo\\ bar'],

            'BLARG_SEARCH_PATHS' => 'foo $(inherited) "YYYYY BOO" h"g" \"ab c\" foo\ bar',
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

      it 'turns array values into strings' do
        @configuration.build_settings = {
          'OTHER_LDFLAGS' => ['-no'],
          'RANDOM_BUILD_SETTING' => ['a', 'b', '"c"'],
        }
        @configuration.to_hash.should == {
          'isa' => 'XCBuildConfiguration',
          'buildSettings' => {
            'OTHER_LDFLAGS' => '-no',
            'RANDOM_BUILD_SETTING' => 'a b "c"',
          },
        }
      end

      it 'keeps quotes when splitting arrays' do
        @configuration.build_settings = {
          'OTHER_LDFLAGS' => 'a "bc def" g"h"',
        }
        @configuration.to_hash.should == {
          'isa' => 'XCBuildConfiguration',
          'buildSettings' => {
            'OTHER_LDFLAGS' => ['a', '"bc def"', 'g"h"'],
          },
        }
      end
    end

    #-------------------------------------------------------------------------#
  end
end
