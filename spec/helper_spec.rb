require File.expand_path('../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Helper::TargetDiff do
    before do
      @target1 = @project.new_target(:static_library, 'Target 1', :ios)
      @target1.add_file_references([@project.new_file('/file/1')])

      @target2 = @project.new_target(:static_library, 'Target 2', :ios)
      @target2.add_file_references([@project.new_file('/file/1'), @project.new_file('/file/3'), @project.new_file('/file/2')])

      @differ = Xcodeproj::Helper::TargetDiff.new(@project, 'Target 1', 'Target 2')
    end

    it 'initalizes with a project and the targets to diff' do
      @differ.project.should.eql @project
      @differ.target1.should == @target1
      @differ.target2.should == @target2
    end

    it 'lists source build files that have been added in target 2, sorted by path' do
      @differ.new_source_build_files.should == @target2.source_build_phase.files.last(2).reverse
    end
  end
end
