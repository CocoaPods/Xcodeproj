require File.expand_path('../spec_helper', __FILE__)

describe "Xcodeproj::Config" do
  extend SpecHelper::TemporaryDirectory

  before do
    @hash = { 'OTHER_LD_FLAGS' => '-framework Foundation' }
    @config = Xcodeproj::Config.new(@hash)
    @config_fixture = fixture_path('oneline-key-value.xcconfig')
  end

  it "can be created with hash" do
    config = Xcodeproj::Config.new(@hash)
    config.should.be.equal @hash
  end

  it "can be created with file path" do
    config = Xcodeproj::Config.new(@config_fixture)
    config.should.be.equal @hash
  end

  it "can be created with File instance" do
    xcconfig_file = File.new(@config_fixture)
    xcconfig = Xcodeproj::Config.new(xcconfig_file)
    xcconfig.should.be.equal @hash
  end

  it "can be serialized with #to_s" do
    @config.to_s.should.be.equal "OTHER_LD_FLAGS = -framework Foundation"
  end

  it "can be serialized with #to_hash" do
    @config.to_hash.should.be.equal @hash
  end

  it "does not serialize with #to_s when inspecting the object" do
    @config.inspect.should == @config.to_hash.inspect
  end

  it "can be compared with other instances" do
    config_dupe = Xcodeproj::Config.new(@hash)
    config_dupe.should.be.equal @config
  end

  it "merges another config hash in place" do
    @config.merge!('HEADER_SEARCH_PATHS' => '/some/path')
    @config.should == {
      'OTHER_LD_FLAGS' => '-framework Foundation',
      'HEADER_SEARCH_PATHS' => '/some/path'
    }
  end

  it "appends a value for the same key when merging" do
    @config.merge!('OTHER_LD_FLAGS' => '-l xml2.2.7.3')
    @config.should == {
      'OTHER_LD_FLAGS' => '-framework Foundation -l xml2.2.7.3'
    }
  end

  it "creates the config file" do
    @config.merge!('HEADER_SEARCH_PATHS' => '/some/path')
    @config.merge!('OTHER_LD_FLAGS' => '-l xml2.2.7.3')
    @config.save_as(temporary_directory + 'Pods.xcconfig')
    (temporary_directory + 'Pods.xcconfig').read.split("\n").sort.should == [
      "OTHER_LD_FLAGS = -framework Foundation -l xml2.2.7.3",
      "HEADER_SEARCH_PATHS = /some/path"
    ].sort
  end

  it "contains file path refs to all included xcconfigs" do
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
      'Key4' => ''
    }
  end

  it 'can be created from file with comments inside' do
    config = Xcodeproj::Config.new(fixture_path('with-comments.xcconfig'))
    config.should == { 'Key' => 'Value' }
  end

end
