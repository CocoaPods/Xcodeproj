require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe AbstractBuildPhase do

    before do
      # Can't initialize AbstractBuildPhase directly
      @sut = @project.new(PBXCopyFilesBuildPhase)
    end

    #----------------------------------------#

    describe "#add_file_reference" do

      it "can add a file reference to its build files" do
        file = @project.new_file('some/file')
        @sut.add_file_reference(file)
        @sut.files_references.should.include(file)
      end

      it "can prevent duplicates while adding a file reference" do
        file = @project.new_file('some/file')
        @sut.add_file_reference(file, true)
        @sut.add_file_reference(file, true)
        @sut.files_references.should == [file]
      end

    end

    #----------------------------------------#

    it "returns the files it's associated with through its build files" do
      file = @project.new_file('some/file')
      @sut.add_file_reference(file)
      @sut.files_references.should == [file]
    end

    it "returns the display names of the build files" do
      @sut.add_file_reference(@project.new_file('file_1'))
      @sut.add_file_reference(@project.new_file('file_2'))
      @sut.file_display_names.should == ["file_1", "file_2"]
    end

    it "returns whether it includes the given build file" do
      f1 = @project.new_file('file_1')
      build_file = @sut.add_file_reference(f1)
      @sut.build_file(f1).should == build_file
    end

    it "returns whether it includes the given build file" do
      f1 = @project.new_file('file_1')
      f2 = @project.new_file('file_2')
      @sut.add_file_reference(f1)
      @sut.should.include?(f1)
      @sut.should.not.include?(f2)
    end

    it "updates build files of a file" do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      file = @project.new_file('Ruby.m')
      @target.source_build_phase.add_file_reference(file)
      @target.source_build_phase.files.count.should == 1
      file.build_files.count.should == 1
      file.build_files.first.file_ref.should == file
    end

    it "removes a build file" do
      file = @project.new_file('Ruby.m')
      build_file = @sut.add_file_reference(file)
      file.build_files.count.should == 1
      @sut.files.count.should == 1

      @sut.remove_file_reference(file)
      file.build_files.count.should == 0
      @sut.files.count.should == 0
      @project.objects.find { |obj| obj == build_file }.should == nil
    end

    it "removes all the build files from a phase" do
      files = []
      3.times do |i|
        file = @project.new_file("file #{i}")
        files << file
        @sut.add_file_reference(file)
        file.referrers.count.should == 2
      end
      @sut.files.count.should == 3
      @sut.clear_build_files
      @sut.files.count.should == 0
      files.each { |f| f.referrers.count.should == 1 }
    end

    it "concrete implementations subclass it" do
      concrete_classes = [
        PBXHeadersBuildPhase,
        PBXSourcesBuildPhase,
        PBXFrameworksBuildPhase,
        PBXResourcesBuildPhase,
        PBXCopyFilesBuildPhase,
        PBXShellScriptBuildPhase
      ]
      concrete_classes.each do |klass|
        (klass < AbstractBuildPhase).should.be.true
      end
    end

    it "does not raise an exception when removing a file that is not in the build phase" do
      file = @project.main_group.new_file("test.png")
      lambda { @sut.remove_file_reference(file) }.should.not.raise(NoMethodError)
    end
  end

  describe PBXCopyFilesBuildPhase do

    before do
      @sut = @project.new(PBXCopyFilesBuildPhase)
    end

    it "is a AbstractBuildPhase" do
      @sut.should.be.kind_of AbstractBuildPhase
    end

    it "returns and empty default dstPath" do
      @sut.dst_path.should == ''
    end

    it "defaults the dstSubfolderSpec to the resources folder" do
      @sut.dst_subfolder_spec.should == "7"
    end
  end

  describe PBXShellScriptBuildPhase do

    before do
      @sut = @project.new(PBXShellScriptBuildPhase)
    end

    it "uses the shell in /bin/sh as the default interpreter" do
      @sut.shell_path.should == '/bin/sh'
    end

    it "has empty defaults for the other attributes" do
      @sut.files.should == []
      @sut.input_paths.should == []
      @sut.output_paths.should == []
      @sut.shell_script.should == ''
    end

    it "returns wether or not env vars should be shown in the log" do
      @sut.show_env_vars_in_log.should == '1'
      @sut.show_env_vars_in_log = '0'
      @sut.show_env_vars_in_log.should == '0'
    end
  end
end
