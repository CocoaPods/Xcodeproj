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
        DevToolsCore.stubs(:load_xcode_frameworks).returns(nil)
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
        DevToolsCore.stubs(:load_xcode_frameworks).returns(nil)
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
        lambda { Xcodeproj.read_plist('doesnotexist') }.should.raise Xcodeproj::Informative
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
          'true_bool' => '1',
          'false_bool' => '0',
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

    #-------------------------------------------------------------------------#

    describe 'Xcode frameworks resilience' do
      extend SpecHelper::TemporaryDirectory

      after do
        if @original_xcode_path
          DevToolsCore.send(:remove_const, :XCODE_PATH)
          DevToolsCore.const_set(:XCODE_PATH, @original_xcode_path)
        end
      end

      def read_sample
        dir = 'Sample Project/Cocoa Application.xcodeproj/'
        path = fixture_path(dir + 'project.pbxproj')
        Xcodeproj.read_plist(path)
      end

      def stub_xcode_path(stubbed_path)
        @original_xcode_path = DevToolsCore::XCODE_PATH
        DevToolsCore.send(:remove_const, :XCODE_PATH)
        DevToolsCore.const_set(:XCODE_PATH, stubbed_path)
      end

      def write_temp_file_and_compare(sample)
        temp_file = File.join(SpecHelper.temporary_directory, 'out.pbxproj')
        Xcodeproj.write_plist(sample, temp_file)
        result = Xcodeproj.read_plist(temp_file)

        sample.should == result
        File.new(temp_file).read.start_with?('<?xml').should == true
      end

      it 'will fallback to XML encoding if Xcode is not installed' do
        # Simulate this by calling `xcrun` with a non-existing tool
        stub_xcode_path(Pathname.new(`xcrun lol 2>/dev/null`))

        write_temp_file_and_compare(read_sample)
      end

      it 'will fallback to XML encoding if the user has not agreed to the Xcode license' do
        stub_xcode_path(Pathname.new('Agreeing to the Xcode/iOS license requires admin privileges, please re-run as root via sudo.'))

        write_temp_file_and_compare(read_sample)
      end

      it 'will fallback to XML encoding if Xcode functions cannot be found' do
        DevToolsCore.stubs(:load_xcode_frameworks).returns(Fiddle::Handle.new)

        write_temp_file_and_compare(read_sample)
      end

      it 'will fallback to XML encoding if Xcode methods return errors' do
        DevToolsCore::NSData.any_instance.stubs(:writeToFileAtomically).returns(false)

        write_temp_file_and_compare(read_sample)
      end

      it 'will fallback to XML encoding if Xcode classes cannot be found' do
        DevToolsCore::NSObject.stubs(:objc_class).returns(nil)

        write_temp_file_and_compare(read_sample)
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Xcode equivalency' do
      extend SpecHelper::TemporaryDirectory

      def setup_fixture(name)
        fixture_path("Sample Project/#{name}/project.pbxproj")
      end

      def setup_temporary(name)
        dir = File.join(SpecHelper.temporary_directory, name)
        FileUtils.mkdir_p(dir)
        File.join(dir, 'project.pbxproj')
      end

      def touch_project(name)
        fixture = setup_fixture(name)
        temporary = setup_temporary(name)

        hash = Xcodeproj.read_plist(fixture)
        Xcodeproj.write_plist(hash, temporary)

        File.open(fixture).read.should == File.open(temporary).read
      end

      it 'touches the project at the given path' do
        touch_project('Cocoa Application.xcodeproj')
      end

      it 'retains emoji when touching a project' do
        touch_project('Emoji.xcodeproj')
      end
    end
  end
end
