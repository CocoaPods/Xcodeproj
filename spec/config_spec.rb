require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Config do
  describe 'In general' do
    extend SpecHelper::TemporaryDirectory

    before do
      @hash = { 'OTHER_LDFLAGS' => '-framework "Foundation"' }
      @config = Xcodeproj::Config.new(@hash)
      @config_fixture = fixture_path('oneline-key-value.xcconfig')
    end

    it 'can be created with hash' do
      config = Xcodeproj::Config.new(@hash)
      config.should.be.equal @hash
    end

    it 'can be created with file path' do
      config = Xcodeproj::Config.new(@config_fixture)
      config.should.be.equal @hash
    end

    it 'can be created with File instance' do
      xcconfig_file = File.new(@config_fixture)
      xcconfig = Xcodeproj::Config.new(xcconfig_file)
      xcconfig.should.be.equal @hash
    end

    it 'does not modifies the hash used for initialization' do
      original = @hash.dup
      Xcodeproj::Config.new(@hash)
      @hash.should.be.equal original
    end

    it 'parses the frameworks and the libraries' do
      hash = { 'OTHER_LDFLAGS' => '-framework Foundation -weak_framework Twitter -lxml2.2.7.3' }
      config = Xcodeproj::Config.new(hash)
      config.frameworks.to_a.should.be.equal %w(Foundation)
      config.weak_frameworks.to_a.should.be.equal %w(Twitter)
      config.libraries.to_a.should.be.equal %w(xml2.2.7.3)
    end

    it 'can be serialized with #to_s' do
      @config.to_s.should.be.equal 'OTHER_LDFLAGS = -framework "Foundation"'
    end

    it 'sorts the internal data by setting name when serializing with #to_s' do
      config = Xcodeproj::Config.new('Y' => '2', 'Z' => '3', 'X' => '1')
      config.to_s.should == "X = 1\nY = 2\nZ = 3"
    end

    it 'can be serialized with #to_hash' do
      @config.to_hash.should.be.equal @hash
    end

    it 'can prefix values during serialization' do
      @prefix_hash = { 'PODS_PREFIX_OTHER_LDFLAGS' => @hash['OTHER_LDFLAGS'] }
      @config.to_hash('PODS_PREFIX_').should.be.equal @prefix_hash
    end

    it 'does not serialize with #to_s when inspecting the object' do
      @config.inspect.should == @config.to_hash.inspect
    end

    it 'can be compared with other instances' do
      config_dupe = Xcodeproj::Config.new(@hash)
      config_dupe.should.be.equal @config
    end

    it 'merges another config hash in place' do
      @config.merge!('HEADER_SEARCH_PATHS' => '/some/path')
      @config.should == {
        'OTHER_LDFLAGS' => '-framework "Foundation"',
        'HEADER_SEARCH_PATHS' => '/some/path',
      }
    end

    it 'merges another config hash in place with the `<<` shortcut' do
      @config << { 'HEADER_SEARCH_PATHS' => '/some/path' }
      @config.should == {
        'OTHER_LDFLAGS' => '-framework "Foundation"',
        'HEADER_SEARCH_PATHS' => '/some/path',
      }
    end

    it 'merges another hash in a new one' do
      new = @config.merge('HEADER_SEARCH_PATHS' => '/some/path')
      new.object_id.should.not == @config.object_id
      new.should == {
        'OTHER_LDFLAGS' => '-framework "Foundation"',
        'HEADER_SEARCH_PATHS' => '/some/path',
      }
      @config.should == { 'OTHER_LDFLAGS' => '-framework "Foundation"' }
    end

    it 'appends a value for the same key when merging' do
      @config.merge!('OTHER_LDFLAGS' => '-l xml2.2.7.3')
      @config.should == {
        'OTHER_LDFLAGS' => '-l"xml2.2.7.3" -framework "Foundation"',
      }
    end

    it 'generates the config file with refs to all included xcconfigs' do
      @config.includes = ['Somefile.xcconfig']
      @config.to_s.split("\n").first.should == '#include "Somefile.xcconfig"'
    end

    it 'appends the extension to the included files if needed' do
      @config.includes = ['Somefile']
      @config.to_s.split("\n").first.should == '#include "Somefile.xcconfig"'
    end

    it 'creates the config file' do
      @config.merge!('HEADER_SEARCH_PATHS' => '/some/path')
      @config.merge!('OTHER_LDFLAGS' => '-l xml2.2.7.3')
      @config.save_as(temporary_directory + 'Pods.xcconfig')
      (temporary_directory + 'Pods.xcconfig').read.split("\n").sort.should == [
        'OTHER_LDFLAGS = -l"xml2.2.7.3" -framework "Foundation"',
        'HEADER_SEARCH_PATHS = /some/path',
      ].sort
    end

    it 'does not rewrite the config file if contents have not changed' do
      filename = temporary_directory + 'Pods.xcconfig'

      def filename.open(mode)
        @writing_count ||= 0
        @writing_count += 1

        super
      end

      @config.save_as(filename)
      @config.save_as(filename)
      filename.instance_variable_get(:@writing_count).should == 1
    end

    it 'contains file path refs to all included xcconfigs' do
      config = Xcodeproj::Config.new(fixture_path('include.xcconfig'))
      config.includes.size.should.be.equal 1
      config.includes.first.should.be.equal 'Somefile'
    end

    it 'can be created from multiline file' do
      config = Xcodeproj::Config.new(fixture_path('sample.xcconfig'))
      config.should == {
        'Key1' => 'Value1 Value2',
        'Key2' => 'Value3 Value4 Value5',
        'Key3' => 'Value6',
        'Key4' => '',
      }
    end

    it 'can be created from file with comments inside' do
      config = Xcodeproj::Config.new(fixture_path('with-comments.xcconfig'))
      config.should == { 'Key' => 'Value' }
    end

    it 'can be created from file with subscripts' do
      config = Xcodeproj::Config.new(fixture_path('subscript.xcconfig'))
      config.should == {
        'CODE_SIGN_IDENTITY[sdk=iphoneos*]' => 'iPhone Developer',
      }
    end

    it "doesn't duplicate libraries and frameworks" do
      hash = { 'OTHER_LDFLAGS' => '-framework Foundation -weak_framework Twitter -lxml2.2.7.3' }
      config = Xcodeproj::Config.new(hash)
      # merge the original hash again
      config.merge!(hash)
      config.frameworks.add 'Foundation'
      config.weak_frameworks.add 'Twitter'
      config.libraries.add 'xml2.2.7.3'
      config.frameworks.to_a.should.be.equal %w(Foundation)
      config.weak_frameworks.to_a.should.be.equal %w(Twitter)
      config.libraries.to_a.should.be.equal %w(xml2.2.7.3)
    end

    it "doesn't duplicate other attribute values" do
      hash = { 'CLANG_CXX_LIBRARY' => 'libc++' }
      config = Xcodeproj::Config.new(hash)
      config.merge!(hash)
      config.to_hash.should == hash
      config.merge!(config)
      config.to_hash.should == hash
    end

    it 'it preserves OTHER_LDFLAGS not related to libraries and frameworks' do
      config1 = Xcodeproj::Config.new('OTHER_LDFLAGS' => %w(-ObjC -fobjc-arc).join(' '))
      config2 = Xcodeproj::Config.new('OTHER_LDFLAGS' => '-framework SystemConfiguration')
      config1.merge! config2
      config1.to_hash['OTHER_LDFLAGS'].should == '-ObjC -fobjc-arc -framework "SystemConfiguration"'
    end

    it 'merges frameworks and libraries from another Config instance' do
      hash = { 'OTHER_LDFLAGS' => '-framework Foundation -weak_framework Twitter -lxml2.2.7.3' }
      config = Xcodeproj::Config.new
      config.merge!(Xcodeproj::Config.new(hash))
      config.frameworks.to_a.should.be.equal %w(Foundation)
      config.weak_frameworks.to_a.should.be.equal %w(Twitter)
      config.libraries.to_a.should.be.equal %w(xml2.2.7.3)
    end

    it 'specifies libraries in the OTHER_LDFLAGS in a format compatible with libtool' do
      hash = { 'OTHER_LDFLAGS' => '-lxml2.2.7.3' }
      config = Xcodeproj::Config.new(hash)
      config.to_hash['OTHER_LDFLAGS'].should.not == '-l "xml2.2.7.3"'
      config.to_hash['OTHER_LDFLAGS'].should == '-l"xml2.2.7.3"'
    end

    it 'does not drop the -force_load argument in case of repeated use' do
      config = Xcodeproj::Config.new
      config.merge!('OTHER_LDFLAGS' => '-force_load a')
      config.merge!('OTHER_LDFLAGS' => '-l"b"')
      config.merge!('OTHER_LDFLAGS' => '-force_load c')
      config.to_hash['OTHER_LDFLAGS'].should == '-l"b" -force_load a -force_load c'
    end

    it 'does not mix up the location of the -force_load argument' do
      config = Xcodeproj::Config.new
      config.merge!('OTHER_LDFLAGS' => '-ObjC')
      config.merge!('OTHER_LDFLAGS' => '-force_load $(PODS_ROOT)/Intercom/Intercom/libIntercom.a')
      config.merge!('OTHER_LDFLAGS' => '-l"Pods-GoogleAnalytics-iOS-SDK"')
      config.merge!('OTHER_LDFLAGS' => '-l"Pods-Intercom"')
      config.to_hash['OTHER_LDFLAGS'].should == '-ObjC -l"Pods-GoogleAnalytics-iOS-SDK" -l"Pods-Intercom" -force_load $(PODS_ROOT)/Intercom/Intercom/libIntercom.a'
    end
  end

  #---------------------------------------------------------------------------#

  describe 'Private helpers' do
    before do
      @config = Xcodeproj::Config.new
    end

    describe '#normalized_xcconfig_path' do
      it 'appends the extension if needed' do
        normalized_path = @config.send(:normalized_xcconfig_path, 'path/file')
        normalized_path.should == 'path/file.xcconfig'
      end

      it "doesn't append the extension if not needed" do
        normalized_path = @config.send(:normalized_xcconfig_path, 'path/file')
        normalized_path.should == 'path/file.xcconfig'
      end
    end
  end

  #---------------------------------------------------------------------------#
end
