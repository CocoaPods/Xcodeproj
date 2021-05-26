require File.expand_path('../../spec_helper', __FILE__)

describe Xcodeproj::Config::OtherLinkerFlagsParser do
  before do
    @parser = Xcodeproj::Config::OtherLinkerFlagsParser
  end

  describe 'In general' do
    it 'detects frameworks' do
      flags = '-framework Foundation'
      @parser.parse(flags).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects frameworks specified with quotes' do
      flags = '-framework "Foundation"'
      @parser.parse(flags).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects weak frameworks' do
      flags = '-weak_framework Twitter'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => ['Twitter'],
        :libraries => [],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects libraries' do
      flags = '-l xml2.2.7.3'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['xml2.2.7.3'],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects libraries specified without a space' do
      flags = '-lxml2.2.7.3'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['xml2.2.7.3'],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects libraries specified with quotes' do
      flags = '-l "Pods-AFNetworking iOS Example-AFNetworking"'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['Pods-AFNetworking iOS Example-AFNetworking'],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects libraries specified with quotes without a space' do
      flags = '-l"Pods-AFNetworking iOS Example-AFNetworking"'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['Pods-AFNetworking iOS Example-AFNetworking'],
        :arg_files => [],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects non categorized other linker flags' do
      flags = '-ObjC -fobjc-arc'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => [],
        :simple => ['-ObjC', '-fobjc-arc'],
        :force_load => [],
      }
    end

    it 'detects arg files' do
      flags = '@ /path/to/file'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => ['/path/to/file'],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects arg files specified with quotes' do
      flags = '@ "${PODS_ROOT}/Target Support Files/Target/other_ldflags"'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => ['${PODS_ROOT}/Target Support Files/Target/other_ldflags'],
        :simple => [],
        :force_load => [],
      }
    end

    it 'detects arg files specified with quotes without a space' do
      flags = '@"${PODS_ROOT}/Target Support Files/Target/other_ldflags"'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => ['${PODS_ROOT}/Target Support Files/Target/other_ldflags'],
        :simple => [],
        :force_load => [],
      }
    end

    it 'strips unnecessary whitespace' do
      flags = '  -ObjC  '
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => [],
        :simple => ['-ObjC'],
        :force_load => [],
      }
    end

    it "doesn't recognize as library flags including but not starting with the `-l` string" do
      flags = '-finalize -prefinalized-library'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => [],
        :simple => ['-finalize', '-prefinalized-library'],
        :force_load => [],
      }
    end

    it 'handles flags containing multiple tokens' do
      flags = ['-framework Foundation']
      flags << '-weak_framework Twitter'
      flags << '-l xml2.2.7.3'
      flags << '-lxml2.2.7.3'
      flags << '-l "Pods-AFNetworking iOS Example-AFNetworking"'
      flags << '-l"Pods-AFNetworking iOS Example-AFNetworking"'
      flags << '@"${PODS_ROOT}/Target Support Files/other_ldflags"'
      flags << '@ "${PODS_ROOT}/Target Support Files/other_ldflags"'
      flags << '-ObjC -fobjc-arc'
      flags << '-finalize -prefinalized-library'
      @parser.parse(flags.join(' ')).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => ['Twitter'],
        :libraries => ['xml2.2.7.3', 'xml2.2.7.3', 'Pods-AFNetworking iOS Example-AFNetworking', 'Pods-AFNetworking iOS Example-AFNetworking'],
        :arg_files => ['${PODS_ROOT}/Target Support Files/other_ldflags', '${PODS_ROOT}/Target Support Files/other_ldflags'],
        :simple => ['-ObjC', '-fobjc-arc', '-finalize', '-prefinalized-library'],
        :force_load => [],
      }
    end

    it 'handles Array flags' do
      flags = %w(-Objc -all_load -lsqlite3 -lz)
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :arg_files => [],
        :simple => ['-Objc', '-all_load', '-lsqlite3', '-lz'],
        :force_load => [],
      }
    end
  end
end
