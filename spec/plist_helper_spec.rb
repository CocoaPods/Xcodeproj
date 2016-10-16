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
        Plist.write_to_path(hash, @plist)
        result = Plist.read_from_path(@plist)
        result.should == hash
        @plist.read.should.include('?xml')
      end

      it 'reads an ASCII plist file' do
        dir = 'Sample Project/Cocoa Application.xcodeproj/'
        path = fixture_path(dir + 'project.pbxproj')
        result = Plist.read_from_path(path)
        result.keys.should.include?('archiveVersion')
      end

      it 'saves a plist file to be consistent with Xcode' do
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

        hash = { 'archiveVersion' => '1.0' }
        Plist.write_to_path(hash, @plist)
        @plist.read.should == output
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Robustness' do
      extend SpecHelper::TemporaryDirectory

      it 'coerces the given path object to a string path' do
        # @plist is a Pathname
        Plist.write_to_path({}, @plist)
        Plist.read_from_path(@plist).should == {}
      end

      it "raises when the given path can't be coerced into a string path" do
        lambda { Plist.write_to_path({}, Object.new) }.should.raise TypeError
      end

      it "raises if the given path doesn't exist" do
        lambda { Plist.read_from_path('doesnotexist') }.should.raise Xcodeproj::Informative
      end

      it 'coerces the given hash to a Hash' do
        o = Object.new
        def o.to_hash
          { 'from' => 'object' }
        end
        Plist.write_to_path(o, @plist)
        Plist.read_from_path(@plist).should == { 'from' => 'object' }
      end

      it "raises when given a hash that can't be coerced to a Hash" do
        lambda { Plist.write_to_path(Object.new, @plist) }.should.raise TypeError
      end

      it 'coerces keys to strings' do
        Plist.write_to_path({ 1 => '1', :symbol => 'symbol' }, @plist)
        Plist.read_from_path(@plist).should == { '1' => '1', 'symbol' => 'symbol' }
      end

      it 'allows hashes, strings, booleans, numbers, and arrays of hashes and strings as values' do
        hash = {
          'hash' => { 'a hash' => 'in a hash' },
          'string' => 'string',
          'true_bool' => '1',
          'false_bool' => '0',
          'integer' => 42,
          'float' => 0.5,
          'array' => ['string in an array', { 'a hash' => 'in an array' }],
        }
        Plist.write_to_path(hash, @plist)
        Plist.read_from_path(@plist).should == hash
      end

      it 'coerces values to strings if it is a disallowed type' do
        Plist.write_to_path({ '1' => 9_999_999_999_999_999_999_999_999, 'symbol' => :symbol }, @plist)
        Plist.read_from_path(@plist).should == { '1' => 9_999_999_999_999_999_999_999_999, 'symbol' => 'symbol' }
      end

      it 'handles unicode characters in paths and strings' do
        plist = @plist.to_s + 'øµ'
        Plist.write_to_path({ 'café' => 'før yoµ' }, plist)
        Plist.read_from_path(plist).should == { 'café' => 'før yoµ' }
      end

      it 'supports date objects' do
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
        Plist.read_from_path(@plist).should == { 'uhoh' => Time.parse('2004-03-03T01:02:03Z') }
      end

      it 'serializes dictionaries in order' do
        Plist.write_to_path({ 'z' => 'z', 'a' => 'a' }, @plist)
        expected = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>a</key>
\t<string>a</string>
\t<key>z</key>
\t<string>z</string>
</dict>
</plist>
EOS
        @plist.read.should == expected
      end

      it 'raises when converting invalid strings' do
        lambda do
          Plist.write_to_path({ 'invalid' => "\xCA" }, @plist)
        end.should.raise ArgumentError, 'invalid byte sequence in UTF-8'
      end

      it 'will not crash when using an empty path' do
        lambda do
          Plist.write_to_path({}, '')
        end.should.raise IOError
      end
    end
  end
end
