# encoding: UTF-8

require File.expand_path('../spec_helper', __FILE__)

module ProjectSpecs
  describe 'Xcodeproj::PlistHelper' do
    before do
      @plist = temporary_directory + 'plist'
    end

    describe 'In general' do
      extend SpecHelper::TemporaryDirectory

      it 'writes an XML plist file' do
        hash = { 'archiveVersion' => '1.0' }
        Xcodeproj.write_plist(hash, @plist)
        result = Xcodeproj.read_plist(@plist)
        result.should == hash
        @plist.read.should.include('?xml')
      end

      it 'reads an ASCII plist file' do
        dir = 'Sample Project/Cocoa Application.xcodeproj/'
        path = fixture_path(dir + 'project.pbxproj')
        result = Xcodeproj.read_plist(path)
        result.keys.should.include?('archiveVersion')
      end

      it 'saves a plist file to be consistent with Xcode' do
        # rubocop:disable Style/Tab
        output = <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>archiveVersion</key>
	<string>1.0</string>
</dict>
</plist>
        PLIST
        # rubocop:enable Style/Tab

        hash = { 'archiveVersion' => '1.0' }
        Xcodeproj.write_plist(hash, @plist)
        @plist.read.should == output
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Robustness' do
      extend SpecHelper::TemporaryDirectory

      it 'coerces the given path object to a string path' do
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

      it 'coerces the given hash to a Hash' do
        o = Object.new
        def o.to_hash
          { 'from' => 'object' }
        end
        Xcodeproj.write_plist(o, @plist)
        Xcodeproj.read_plist(@plist).should == { 'from' => 'object' }
      end

      it "raises when given a hash that can't be coerced to a Hash" do
        lambda { Xcodeproj.write_plist(Object.new, @plist) }.should.raise TypeError
      end

      it 'coerces keys to strings' do
        Xcodeproj.write_plist({ 1 => '1', :symbol => 'symbol' }, @plist)
        Xcodeproj.read_plist(@plist).should == { '1' => '1', 'symbol' => 'symbol' }
      end

      it 'allows hashes, strings, booleans, numbers, and arrays of hashes and strings as values' do
        hash = {
          'hash'   => { 'a hash' => 'in a hash' },
          'string' => 'string',
          'true_bool' => true,
          'false_bool' => false,
          'integer' => 42,
          'float' => 0.5,
          'array'  => ['string in an array', { 'a hash' => 'in an array' }],
        }
        Xcodeproj.write_plist(hash, @plist)
        Xcodeproj.read_plist(@plist).should == hash
      end

      it 'coerces values to strings if it is a disallowed type' do
        Xcodeproj.write_plist({ '1' => 9_999_999_999_999_999_999_999_999, 'symbol' => :symbol }, @plist)
        Xcodeproj.read_plist(@plist).should == { '1' => '9999999999999999999999999', 'symbol' => 'symbol' }
      end

      it 'handles unicode characters in paths and strings' do
        plist = @plist.to_s + 'øµ'
        Xcodeproj.write_plist({ 'café' => 'før yoµ' }, plist)
        Xcodeproj.read_plist(plist).should == { 'café' => 'før yoµ' }
      end

      it 'raises if a plist contains any non-supported object type' do
        @plist.open('w') do |f|
          f.write <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>uhoh</key>
  <date>2004-03-03T01:02:03Z</date>
</dict>
</plist>
EOS
        end
        lambda { Xcodeproj.read_plist(@plist) }.should.raise TypeError
      end

      it 'raises if a plist array value contains any non-supported object type' do
        @plist.open('w') do |f|
          f.write <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>uhoh</key>
  <array>
    <date>2004-03-03T01:02:03Z</date>
  </array>
</dict>
</plist>
EOS
        end
        lambda { Xcodeproj.read_plist(@plist) }.should.raise TypeError
      end

      it 'raises if for whatever reason the value could not be converted to a CFTypeRef' do
        lambda do
          Xcodeproj.write_plist({ 'invalid' => "\xCA" }, @plist)
        end.should.raise TypeError
      end

      it 'will not crash when using an empty path' do
        lambda do
          Xcodeproj.write_plist({}, '')
        end.should.raise IOError
      end
    end
  end
end
