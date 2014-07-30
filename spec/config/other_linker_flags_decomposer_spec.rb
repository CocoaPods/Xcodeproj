require File.expand_path('../../spec_helper', __FILE__)

describe Xcodeproj::Config::OtherLinkerFlagsDecomposer do
  before do
    @decomposer = Xcodeproj::Config::OtherLinkerFlagsDecomposer
  end

  describe "In general" do
    it "detects frameworks" do
      flags = '-framework Foundation'
      @decomposer.decompose(flags).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => [],
        :libraries => [],
        :simple => [],
      }
    end

    it "detects weak frameworks" do
      flags = '-weak_framework Twitter'
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => ['Twitter'],
        :libraries => [],
        :simple => [],
      }
    end

    it "detects libraries" do
      flags = '-l xml2.2.7.3'
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['xml2.2.7.3'],
        :simple => [],
      }
    end

    it "detects libraries specified without a space" do
      flags = '-lxml2.2.7.3'
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['xml2.2.7.3'],
        :simple => [],
      }
    end

    it "detects libraries specified with quotes" do
      flags = %Q(-l "Pods-AFNetworking iOS Example-AFNetworking")
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['Pods-AFNetworking iOS Example-AFNetworking'],
        :simple => [],
      }
    end

    it "detects libraries specified with quotes without a space" do
      flags = %Q(-l"Pods-AFNetworking iOS Example-AFNetworking")
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => ['Pods-AFNetworking iOS Example-AFNetworking'],
        :simple => [],
      }
    end

    it "detects non categorized other linker flags" do
      flags = '-ObjC -fobjc-arc'
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :simple => ['-ObjC', '-fobjc-arc'],
      }
    end

    it "strips unnecessary whitespace" do
      flags = '  -ObjC  '
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :simple => ['-ObjC'],
      }
    end

    it "doesn't recognize as library flags including but not starting with the `-l` string" do
      flags = '-finalize -prefinalized-library'
      @decomposer.decompose(flags).should == {
        :frameworks => [],
        :weak_frameworks => [],
        :libraries => [],
        :simple => ['-finalize', '-prefinalized-library'],
      }
    end

    it "handles flags containing multiple tokens" do
      flags = ['-framework Foundation']
      flags << '-weak_framework Twitter'
      flags << '-l xml2.2.7.3'
      flags << '-lxml2.2.7.3'
      flags << %q(-l "Pods-AFNetworking iOS Example-AFNetworking")
      flags << %q(-l"Pods-AFNetworking iOS Example-AFNetworking")
      flags << '-ObjC -fobjc-arc'
      flags << '-finalize -prefinalized-library'
      @decomposer.decompose(flags.join(' ')).should == {
        :frameworks => ['Foundation'],
        :weak_frameworks => ['Twitter'],
        :libraries => ["xml2.2.7.3", "xml2.2.7.3", "Pods-AFNetworking iOS Example-AFNetworking", "Pods-AFNetworking iOS Example-AFNetworking"],
        :simple => ["-ObjC", "-fobjc-arc", "-finalize", "-prefinalized-library"],
      }
    end
  end
end
