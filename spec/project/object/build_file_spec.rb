require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXBuildFile do

    before do
      @file = @project.new(PBXBuildFile)
    end

    it "defaults the settings to the empty hash" do
      @file.settings.should == {}
    end

    it "returns the file reference" do
      @file.file_ref = @project.new(PBXFileReference)
      @file.file_ref.class.should == PBXFileReference
    end

    it "accepts a variant group and a version group as a reference" do
      lambda { @file.file_ref = @project.new(PBXVariantGroup) }.should.not.raise
      lambda { @file.file_ref = @project.new(XCVersionGroup) }.should.not.raise
    end

    it "has a referrer to the added file reference" do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      file = @project.new_file('Ruby.m')
      build_file = @target.source_build_phase.add_file_reference(file)
      build_file.referrers.should.include file
      file.build_files.count.should == 1
      file.build_files.first.file_ref.should == file
    end

    it "removes a build file" do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      file = @project.new_file('Ruby.m')
      build_file = @target.source_build_phase.add_file_reference(file)
      file.build_files.count.should == 1
      @target.source_build_phase.files.count.should == 1
      
      build_file.remove_from_project
      file.build_files.count.should == 0
      @target.source_build_phase.files.count.should == 0
    end

    it "removes a build file if the referenced file is removed from the project" do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      file = @project.new_file('Ruby.m')
      @target.source_build_phase.add_file_reference(file)
      before = @target.source_build_phase.files_references.count

      file.remove_from_project
      @target.source_build_phase.files_references.count.should == before - 1
    end
    
  end
end

