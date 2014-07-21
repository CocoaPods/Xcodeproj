# encoding: UTF-8

require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::PlistHelper do
  extend SpecHelper::TemporaryDirectory

  before do
    @plist = temporary_directory + 'plist'
  end

  it "coerces the given path object to a string path" do
    # @plist is a Pathname
    Xcodeproj::PlistHelper.write_plist({}, @plist)
    Xcodeproj::PlistHelper.read_plist(@plist).should == {}
  end

  it "raises when the given path can't be coerced into a string path" do
    lambda { Xcodeproj::PlistHelper.write_plist({}, Object.new) }.should.raise TypeError
  end

  it "raises if the given path doesn't exist" do
    lambda { Xcodeproj::PlistHelper.read_plist('doesnotexist') }.should.raise ArgumentError
  end

  it "coerces the given hash to a Hash" do
    o = Object.new
    def o.to_hash; { 'from' => 'object' }; end
    Xcodeproj::PlistHelper.write_plist(o, @plist)
    Xcodeproj::PlistHelper.read_plist(@plist).should == { 'from' => 'object' }
  end

  it "raises when given a hash that can't be coerced to a Hash" do
    lambda { Xcodeproj::PlistHelper.write_plist(Object.new, @plist) }.should.raise TypeError
  end

  it "coerces keys to strings" do
    Xcodeproj::PlistHelper.write_plist({ 1 => '1', :symbol => 'symbol' }, @plist)
    Xcodeproj::PlistHelper.read_plist(@plist).should == { '1' => '1', 'symbol' => 'symbol' }
  end

  it "allows hashes, strings, booleans, and arrays of hashes and strings as values" do
    hash = {
      'hash'   => { 'a hash' => 'in a hash' },
      'string' => 'string',
      'true_bool' => true,
      'false_bool' => false,
      'array'  => ['string in an array', { 'a hash' => 'in an array' }]
    }
    Xcodeproj::PlistHelper.write_plist(hash, @plist)
    Xcodeproj::PlistHelper.read_plist(@plist).should == hash
  end

  it "handles unicode characters in paths and strings" do
    plist = @plist.to_s + 'øµ'
    Xcodeproj::PlistHelper.write_plist({ 'café' => 'før yoµ' }, plist)
    Xcodeproj::PlistHelper.read_plist(plist).should == { 'café' => 'før yoµ' }
  end
end
