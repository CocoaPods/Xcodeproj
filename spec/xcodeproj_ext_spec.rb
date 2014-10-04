# encoding: UTF-8

require File.expand_path('../spec_helper', __FILE__)
require 'xcodeproj/ext'

describe "Xcodeproj plist handling" do
  extend SpecHelper::TemporaryDirectory

  before do
    @plist = temporary_directory + 'plist'
  end

  it "coerces the given path object to a string path" do
    # @plist is a Pathname
    Xcodeproj.write_plist({}, @plist)
    Xcodeproj.read_plist(@plist).should == {}
  end

  it "raises when the given path can't be coerced into a string path" do
    lambda { Xcodeproj.write_plist({}, Object.new) }.should.raise TypeError
  end

  it "raises if the given path doesn't exist" do
    lambda { Xcodeproj.read_plist('doesnotexist') }.should.raise ArgumentError
  end

  it "coerces the given hash to a Hash" do
    o = Object.new
    def o.to_hash; { 'from' => 'object' }; end
    Xcodeproj.write_plist(o, @plist)
    Xcodeproj.read_plist(@plist).should == { 'from' => 'object' }
  end

  it "raises when given a hash that can't be coerced to a Hash" do
    lambda { Xcodeproj.write_plist(Object.new, @plist) }.should.raise TypeError
  end

  it "coerces keys to strings" do
    Xcodeproj.write_plist({ 1 => '1', :symbol => 'symbol' }, @plist)
    Xcodeproj.read_plist(@plist).should == { '1' => '1', 'symbol' => 'symbol' }
  end

  it "allows hashes, strings, booleans, and arrays of hashes and strings as values" do
    hash = {
      'hash'   => { 'a hash' => 'in a hash' },
      'string' => 'string',
      'true_bool' => true,
      'false_bool' => false,
      'array'  => ['string in an array', { 'a hash' => 'in an array' }]
    }
    Xcodeproj.write_plist(hash, @plist)
    Xcodeproj.read_plist(@plist).should == hash
  end

  it "coerces values to strings if it is a disallowed type" do
    Xcodeproj.write_plist({ '1' => 1, 'symbol' => :symbol }, @plist)
    Xcodeproj.read_plist(@plist).should == { '1' => '1', 'symbol' => 'symbol' }
  end

  it "handles unicode characters in paths and strings" do
    plist = @plist.to_s + 'øµ'
    Xcodeproj.write_plist({ 'café' => 'før yoµ' }, plist)
    Xcodeproj.read_plist(plist).should == { 'café' => 'før yoµ' }
  end

  it "raises if a plist contains any other object type as value than string, dictionary, and array" do
    @plist.open('w') do |f|
      f.write <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>uhoh</key>
  <integer>42</integer>
</dict>
</plist>
EOS
    end
    lambda { Xcodeproj.read_plist(@plist) }.should.raise TypeError
  end

  it "raises if a plist array value contains any other object type than string, or dictionary" do
    @plist.open('w') do |f|
      f.write <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>uhoh</key>
  <array>
    <integer>42</integer>
  </array>
</dict>
</plist>
EOS
    end
    lambda { Xcodeproj.read_plist(@plist) }.should.raise TypeError
  end

  it "raises if for whatever reason the value could not be converted to a CFTypeRef" do
    lambda do
      Xcodeproj.write_plist({ "invalid" => "\xCA" }, @plist)
    end.should.raise TypeError
  end
end
