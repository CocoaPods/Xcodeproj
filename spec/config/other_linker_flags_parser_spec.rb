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
        :simple => [],
      }
    end

    it 'detects frameworks specified with quotes' do
      flags = '-framework "Foundation"'
      @parser.parse(flags).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => [],
        :libraries => [],
        :simple => [],
      }
    end

    it 'detects weak frameworks' do
      flags = '-weak_framework Twitter'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => ['Twitter'],
        :libraries => [],
        :simple => [],
      }
    end

    it 'detects libraries' do
      flags = '-l xml2.2.7.3'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['xml2.2.7.3'],
        :simple => [],
      }
    end

    it 'detects libraries specified without a space' do
      flags = '-lxml2.2.7.3'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['xml2.2.7.3'],
        :simple => [],
      }
    end

    it 'detects libraries specified with quotes' do
      flags = '-l "Pods-AFNetworking iOS Example-AFNetworking"'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['Pods-AFNetworking iOS Example-AFNetworking'],
        :simple => [],
      }
    end

    it 'detects libraries specified with quotes without a space' do
      flags = '-l"Pods-AFNetworking iOS Example-AFNetworking"'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['Pods-AFNetworking iOS Example-AFNetworking'],
        :simple => [],
      }
    end

    it 'detects non categorized other linker flags' do
      flags = '-ObjC -fobjc-arc'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :simple => ['-ObjC', '-fobjc-arc'],
      }
    end

    it 'strips unnecessary whitespace' do
      flags = '  -ObjC  '
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :simple => ['-ObjC'],
      }
    end

    it "doesn't recognize as library flags including but not starting with the `-l` string" do
      flags = '-finalize -prefinalized-library'
      @parser.parse(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :simple => ['-finalize', '-prefinalized-library'],
      }
    end

    it 'handles flags containing multiple tokens' do
      flags = ['-framework Foundation']
      flags << '-weak_framework Twitter'
      flags << '-l xml2.2.7.3'
      flags << '-lxml2.2.7.3'
      flags << '-l "Pods-AFNetworking iOS Example-AFNetworking"'
      flags << '-l"Pods-AFNetworking iOS Example-AFNetworking"'
      flags << '-ObjC -fobjc-arc'
      flags << '-finalize -prefinalized-library'
      @parser.parse(flags.join(' ')).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => ['Twitter'],
        :libraries => ['xml2.2.7.3', 'xml2.2.7.3', 'Pods-AFNetworking iOS Example-AFNetworking', 'Pods-AFNetworking iOS Example-AFNetworking'],
        :simple => ['-ObjC', '-fobjc-arc', '-finalize', '-prefinalized-library'],
      }
    end
  end
end
