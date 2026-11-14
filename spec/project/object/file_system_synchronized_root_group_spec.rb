require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXFileSystemSynchronizedRootGroup do
    before do
      @project = Project.new('/path/to/Dummy.xcodeproj')
      @root_group = @project.new(PBXFileSystemSynchronizedRootGroup)
    end

    describe '#to_hash' do
      it "does not include exceptions in its hash if there aren't any" do
        @root_group.to_hash['exceptions'].should.be.nil
      end

      it 'includes exceptions in its hash if it contains at least one' do
        target = @project.new(PBXNativeTarget)
        target.name = "TestTarget"

        exception = @project.new(PBXFileSystemSynchronizedBuildFileExceptionSet)
        exception.target = target
        @root_group.exceptions << exception

        @root_group.to_hash['exceptions'].should == [exception.uuid]
      end
    end
  end
end
