require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::XCProjHelper do

    before do
      @sut = Xcodeproj::Project::XCProjHelper
    end

    #-------------------------------------------------------------------------#

    describe "::available?" do

      it "reports that xcproj is available" do
        Process::Status.any_instance.expects(:exitstatus).returns(0)
        @sut.should.be.available
      end

      it "reports that xcproj is not available" do
        Process::Status.any_instance.expects(:exitstatus).returns(1)
        @sut.should.not.be.available
      end
    end

    #-------------------------------------------------------------------------#

    describe "::touch" do

      it "touches the project with the given path" do
        @sut.expects(:execute).with("xcproj --project /project_path touch").returns(true, '')
        @sut.touch('/project_path')
      end

      it "prints a warning if the execution was not successful" do
        @sut.expects(:execute).with("xcproj --project /project_path touch").returns([true, ''])
        Xcodeproj::UI.expects(:warn).never
        @sut.touch('/project_path')
      end

      it "prints a warning if the execution was not successful" do
        @sut.expects(:execute).with("xcproj --project /project_path touch").returns([false, ''])
        Xcodeproj::UI.expects(:warn).once
        @sut.touch('/project_path')
      end

    end

    #-------------------------------------------------------------------------#

  end
end
