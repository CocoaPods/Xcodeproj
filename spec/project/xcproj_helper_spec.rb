require File.expand_path('../../spec_helper', __FILE__)
require 'xcodeproj/plist_helper'

module ProjectSpecs
  describe Xcodeproj::Project::XCProjHelper do
    before do
      @helper = Xcodeproj::Project::XCProjHelper
    end

    #-------------------------------------------------------------------------#

    describe '::available?' do
      it 'reports that xcproj is available' do
        Process::Status.any_instance.expects(:exitstatus).returns(0)
        @helper.should.be.available
      end
      @fixture = fixture_path('Sample Project/Cocoa Application.xcodeproj/project.pbxproj')

      dir = File.join(SpecHelper.temporary_directory, 'Cocoa Application.xcodeproj')
      FileUtils.mkdir_p(dir)
      @output = File.join(dir, 'project.pbxproj')
    end

    #-------------------------------------------------------------------------#

    describe '::touch' do
      before do
        @helper.stubs(:available?).returns(true)
      end

      it 'touches the project at the given path' do
        hash = Xcodeproj.read_plist(@fixture)
        Xcodeproj.write_plist(hash, @output)

        result = @helper.touch(@output)

        result.should == 1
        File.open(@fixture).read.should == File.open(@output).read
      end
    end

    #-------------------------------------------------------------------------#
  end
end
