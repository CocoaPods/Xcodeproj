require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe XCBuildConfiguration do

    before do
      @sut = @project.new(XCBuildConfiguration)
    end

    describe "In general" do

      it "returns its name" do
        @sut.name = "Release"
        @sut.name.should == "Release"
      end

      it "returns the empty hash as default build settings" do
        @sut.build_settings.should == {}
      end

      it "returns the xcconfig that this configuration is based on" do
        xcconfig = @project.new_file('file.xcconfig')
        @sut.base_configuration_reference = xcconfig
        @sut.base_configuration_reference.should.be.not.nil
      end
    end

    #-------------------------------------------------------------------------#

    describe "AbstractObject Hooks" do

      it "returns the pretty print representation" do
        @sut.name = "Release"
        @sut.build_settings = {'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES'}
        xcconfig = @project.new_file('file.xcconfig')
        @sut.base_configuration_reference = xcconfig

        @sut.pretty_print.should == {
          "Release" => {
            "Build Settings" => {
              "GCC_PRECOMPILE_PREFIX_HEADER" => "YES"
            },
            "Base Configuration" => "file.xcconfig"
          }
        }
      end

    end

    #-------------------------------------------------------------------------#

    describe "AbstractObject Hooks" do

      it "can be sorted" do
        @sut.name = "Release"
        @sut.build_settings = {'KEY_B' => 'B', 'KEY_A' => 'A'}
        @sut.sort
        @sut.build_settings.keys.should == ["KEY_A", "KEY_B"]
      end

    end

    #-------------------------------------------------------------------------#

  end
end

