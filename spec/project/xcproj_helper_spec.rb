require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::XCProjHelper do

    before do
      @helper = Xcodeproj::Project::XCProjHelper
    end

    #-------------------------------------------------------------------------#

    describe "::available?" do

      it "reports that xcproj is available" do
        Process::Status.any_instance.expects(:exitstatus).returns(0)
        @helper.should.be.available
      end

      it "reports that xcproj is not available" do
        Process::Status.any_instance.expects(:exitstatus).returns(1)
        @helper.should.not.be.available
      end
    end

    #-------------------------------------------------------------------------#

    describe "::touch" do

      before do
        @helper.stubs(:available?).returns(true)
      end

      it "touches the project with the given path" do
        @helper.expects(:execute).with("xcproj --project \"/project_path\" touch").returns(true, '')
        @helper.touch('/project_path')
      end

      it "prints a warning if the execution was not successful" do
        @helper.expects(:execute).with("xcproj --project \"/project_path\" touch").returns([true, ''])
        Xcodeproj::UI.expects(:warn).never
        @helper.touch('/project_path')
      end

      it "prints a warning if the execution was not successful" do
        @helper.expects(:execute).with("xcproj --project \"/project_path\" touch").returns([false, ''])
        Xcodeproj::UI.expects(:warn).once
        @helper.touch('/project_path')
      end

    end

    #-------------------------------------------------------------------------#

  end
end
