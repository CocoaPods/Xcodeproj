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

        it 'returns true when the preprocessor definitions in the config include DEBUG=1' do
          @configuration.name = 'Debug'
          @project.build_settings(@configuration.name)['GCC_PREPROCESSOR_DEFINITIONS'] = ['DEBUG=1']
          @configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['$(inherited)', 'foo']
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

      describe '#resolve_build_setting' do
        before do
          @configuration.build_settings = {
            'i' => 'I',
            'plain_i' => 'i',
            'e' => 'E',
            'IE' => 'nested',
            'thing' => 'should resolve ${i} hop${e}, ${${i}${e}}',
            'other' => '$(inherited) 10 ${inherited}',
            'missing_ref' => '${dsadsadsaFSDFDS}',
            'missing_ref_array' => %w(${dsadsadsaFSDFDS}),
            'prefixed_with_inherited' => '${inherited_suffix}',
            'inherited_suffix' => 'suffix',
            'FOOS' => %w(a b c d ${i} ${inherited} ${I${e}} ${${i}E}),
            'self_recursive' => 'hi $(self_recursive)',
            'mutually_recursive' => 'mn: ${mutually_recursive_nested}',
            'mutually_recursive_nested' => 'm1: ${mutually_recursive_1} m2: ${mutually_recursive_1}',
            'mutually_recursive_1' => 'mr2=${mutually_recursive_2}',
            'mutually_recursive_2' => 'mr1=${mutually_recursive_1}',
            'mixes_braces_and_parens' => '${ab) $(cd}){})',
          }
        end

        it 'resolves build settings that reference other variables' do
          @configuration.resolve_build_setting('thing').should == 'should resolve I hopE, nested'
        end

        it 'resolves build settings that have inherited, but dont inherit a value' do
          @configuration.resolve_build_setting('other').should == ' 10 '
        end

        it 'resolves settings prefixed with inherited' do
          @configuration.resolve_build_setting('prefixed_with_inherited').should == 'suffix'
        end

        it 'resolves array settings with variable references' do
          @configuration.resolve_build_setting('FOOS').should == %w(a b c d I nested nested)
        end

        it 'resolves values that are the name of another setting to the value, not the other setting' do
          @configuration.resolve_build_setting('plain_i').should == 'i'
        end

        it 'resolves missing references to the empty string' do
          @configuration.resolve_build_setting('missing_ref').should == ''
        end

        it 'resolves missing references to the empty string in an array' do
          @configuration.resolve_build_setting('missing_ref_array').should == ['']
        end

        it 'resolves self-recursive references to nil' do
          @configuration.resolve_build_setting('self_recursive').should.nil?
        end

        it 'is stict about a variable only being surrounded by braces or parens' do
          @configuration.resolve_build_setting('mixes_braces_and_parens').should == '${ab) $(cd}){})'
        end

        it 'resolves mutually-recursive references to nil' do
          @configuration.resolve_build_setting('mutually_recursive_1').should.nil?
          @configuration.resolve_build_setting('mutually_recursive_2').should.nil?
          @configuration.resolve_build_setting('mutually_recursive_nested').should.nil?
          @configuration.resolve_build_setting('mutually_recursive').should.nil?
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
          'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphonesimulator*]' => '$(inherited) SIMULATOR=1',
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
            'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphonesimulator*]' => ['$(inherited)', 'SIMULATOR=1'],
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

      it 'keeps empty strings when splitting arrays' do
        @configuration.build_settings = {
          'OTHER_LDFLAGS' => %('' a ""),
        }
        @configuration.to_hash.should == {
          'isa' => 'XCBuildConfiguration',
          'buildSettings' => {
            'OTHER_LDFLAGS' => ["''", 'a', '""'],
          },
        }
      end
    end

    #-------------------------------------------------------------------------#
  end
end
