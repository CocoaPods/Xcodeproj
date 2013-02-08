require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe AbstractBuildPhase do

    before do
      # Can't initialize AbstractBuildPhase directly
      @phase = @project.new(PBXCopyFilesBuildPhase)
    end

    it "has an empty list of (build) files" do
      @phase.files.should == []
    end

    it "is initialized with the default buildActionMask" do
      @phase.build_action_mask.should == "2147483647"
    end

    it "is initialized with the default runOnlyForDeploymentPostprocessing" do
      @phase.run_only_for_deployment_postprocessing.should == "0"
    end

    if "is initialized with empty comments" do
      @phase.comments.should == ""
    end

    it "can add a file reference to its build files" do
      file = @project.new_file('some/file')
      @phase.add_file_reference(file)
      @phase.files_references.should.include file
    end

    it "returns the files it's associated with through its build files" do
      file = @project.new_file('some/file')
      @phase.add_file_reference(file)
      @phase.files_references.should == [file]
    end

    it "updates build files of a file" do
      @target = @project.new_target(:static_library, 'Pods', :ios)
      file = @project.new_file('Ruby.m')
      @target.source_build_phase.add_file_reference(file)
      @target.source_build_phase.files.count.should == 1
      file.build_files.count.should == 1
      file.build_files.first.file_ref.should == file
    end

    it "removes a build file from a build phase" do
      file = @project.new_file('Ruby.m')
      build_file = @phase.add_file_reference(file)
      file.build_files.count.should == 1
      @phase.files.count.should == 1

      @phase.remove_file_reference(file)
      file.build_files.count.should == 0
      @phase.files.count.should == 0
      @project.objects.find { |obj| obj == build_file }.should == nil
    end

    it "removes several build files from a build phase" do
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
      number_of_files = 10

      number_of_files.times do |_|
        random_suffix = (0...10).map{ o[rand(o.length)] }.join
        filename = "file-#{random_suffix}.png"
        file = @project.new_file(filename)
        @phase.add_file_reference(file)
      end
      @phase.files.count.should == number_of_files

      @phase.files.objects.each do |bf|
        @phase.remove_build_file(bf)
      end
      @phase.files.count.should == 0
    end

    it "removes all the build files from a phase" do
      files = []
      3.times do |i|
        file = @project.new_file("file #{i}")
        files << file
        @phase.add_file_reference(file)
        file.referrers.count.should == 2
      end
      @phase.files.count.should == 3
      @phase.clear_build_files
      @phase.files.count.should == 0
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
      lambda { @phase.remove_file_reference(file) }.should.not.raise(NoMethodError)
    end
  end

  describe PBXCopyFilesBuildPhase do

    before do
      @phase = @project.new(PBXCopyFilesBuildPhase)
    end

    it "is a AbstractBuildPhase" do
      @phase.should.be.kind_of AbstractBuildPhase
    end

    it "returns and empty default dstPath" do
      @phase.dst_path.should == ''
    end

    it "defaults the dstSubfolderSpec to the resources folder" do
      @phase.dst_subfolder_spec.should == "7"
    end
  end

  describe PBXShellScriptBuildPhase do

    before do
      @phase = @project.new(PBXShellScriptBuildPhase)
    end

    it "uses the shell in /bin/sh as the default interpreter" do
      @phase.shell_path.should == '/bin/sh'
    end

    it "has empty defaults for the other attributes" do
      @phase.files.should == []
      @phase.input_paths.should == []
      @phase.output_paths.should == []
      @phase.shell_script.should == ''
    end

    it "returns wether or not env vars should be shown in the log" do
      @phase.show_env_vars_in_log.should == '1'
      @phase.show_env_vars_in_log = '0'
      @phase.show_env_vars_in_log.should == '0'
    end
  end
end
