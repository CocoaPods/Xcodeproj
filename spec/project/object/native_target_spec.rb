require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs

  describe AbstractTarget do
    describe "In general" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
        @sut.name.should == "Pods"
        @sut.product_name.should == "Pods"
      end
    end



    #----------------------------------------#

    describe "Helpers" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      describe "#common_resolved_build_setting" do

        it "returns the resolved build setting for the given key as indicated in the target build configuration" do
          @project.build_configuration_list.set_setting('ARCHS', nil)
          @sut.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @sut.resolved_build_setting('ARCHS').should == {"Release"=>"VALID_ARCHS", "Debug"=>"VALID_ARCHS"}
        end

        it "returns the resolved build setting for the given key as indicated in the project build configuration" do
          @project.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @sut.build_configuration_list.set_setting('ARCHS', nil)
          @sut.resolved_build_setting('ARCHS').should == {"Release"=>"VALID_ARCHS", "Debug"=>"VALID_ARCHS"}
        end

        it "overrides the project settings with the target ones" do
          @project.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @sut.build_configuration_list.set_setting('ARCHS', "arm64")
          @sut.resolved_build_setting('ARCHS').should == {"Release"=>"arm64", "Debug"=>"arm64"}
        end

      end

      #----------------------------------------#

      describe "#common_resolved_build_setting" do

        it "returns the common resolved build setting for the given key as indicated in the target build configuration" do
          @project.build_configuration_list.set_setting('ARCHS', nil)
          @sut.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @sut.common_resolved_build_setting('ARCHS').should == "VALID_ARCHS"
        end

        it "returns the common resolved build setting for the given key as indicated in the project build configuration" do
          @project.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @sut.build_configuration_list.set_setting('ARCHS', nil)
          @sut.common_resolved_build_setting('ARCHS').should == "VALID_ARCHS"
        end

        it "raises if the build setting has multiple values across the build configurations" do
          @sut.build_configuration_list.build_configurations.first.build_settings['ARCHS'] = "arm64"
          @sut.build_configuration_list.build_configurations.last.build_settings['ARCHS'] = "VALID_ARCHS"
          should.raise do
            @sut.common_resolved_build_setting('ARCHS')
          end.message.should.match /multiple values/
        end

      end

      #----------------------------------------#

      it "returns the SDK specified in its build configuration" do
        @project.build_configuration_list.set_setting('SDKROOT', nil)
        @sut.build_configuration_list.set_setting('SDKROOT', 'iphoneos')
        @sut.sdk.should == 'iphoneos'
      end

      it "returns the SDK of the project if one is not specified in the build configurations" do
        @project.build_configuration_list.set_setting('SDKROOT', 'iphoneos')
        @sut.build_configuration_list.set_setting('SDKROOT', nil)
        @sut.sdk.should == 'iphoneos'
      end

      it "returns the platform name" do
        @project.new_target(:static_library, 'Pods', :ios).platform_name.should == :ios
        @project.new_target(:static_library, 'Pods', :osx).platform_name.should == :osx
      end

      it "returns the SDK version" do
        @project.new_target(:static_library, 'Pods', :ios).sdk_version.should == nil
        @project.new_target(:static_library, 'Pods', :osx).sdk_version.should == nil

        t1 = @project.new_target(:static_library, 'Pods', :ios)
        t1.build_configuration_list.set_setting('SDKROOT', 'iphoneos7.0')
        t1.sdk_version.should == '7.0'

        t2 = @project.new_target(:static_library, 'Pods', :osx)
        t2.build_configuration_list.set_setting('SDKROOT', 'macosx10.8')
        t2.sdk_version.should == '10.8'
      end

      it "returns the deployment target specified in its build configuration" do
        @project.build_configuration_list.set_setting('IPHONEOS_DEPLOYMENT_TARGET', nil)
        @project.build_configuration_list.set_setting('MACOSX_DEPLOYMENT_TARGET', nil)
        @project.new_target(:static_library, 'Pods', :ios).deployment_target.should == '4.3'
        @project.new_target(:static_library, 'Pods', :osx).deployment_target.should == '10.7'
      end

      it "returns the deployment target" do
        @project.build_configuration_list.set_setting('IPHONEOS_DEPLOYMENT_TARGET', '4.3')
        @project.build_configuration_list.set_setting('MACOSX_DEPLOYMENT_TARGET', '10.7')
        mac_target = @project.new_target(:static_library, 'Pods', :ios)
        mac_target.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = nil
        mac_target.deployment_target.should == '4.3'
      end

      it "returns the build configuration" do
        build_configurations = @sut.build_configurations
        build_configurations.map(&:isa).uniq.should == ['XCBuildConfiguration']
        build_configurations.map(&:name).sort.should == ["Debug", "Release"]
      end

      #----------------------------------------#

      describe "#add_build_configuration" do

        it "adds a new build configuration" do
          @sut.add_build_configuration('App Store', :release)
          @sut.build_configurations.map(&:name).sort.should == [ 'App Store', 'Debug', 'Release' ]
        end

        it "configures new build configurations according to the given type" do
          @sut.add_build_configuration('App Store', :release)
          @sut.build_settings('App Store')['OTHER_CFLAGS'].should == ['-DNS_BLOCK_ASSERTIONS=1', "$(inherited)"]
        end

        it "doesn't duplicate build configurations with existing names" do
          @sut.add_build_configuration('App Store', :release)
          @sut.add_build_configuration('App Store', :release)
          @sut.build_configurations.map(&:name).grep('App Store').size.should == 1
        end

      end

      #----------------------------------------#

      it "returns the build settings of the configuration with the given name" do
        @sut.build_settings('Debug')['PRODUCT_NAME'].should == "$(TARGET_NAME)"
      end

      describe "#add_dependency" do

        it "adds a dependency on another target" do
          dependency_target = @project.new_target(:static_library, 'Pods-SMCalloutView', :ios)
          @sut.add_dependency(dependency_target)
          @sut.dependencies.count.should == 1
          target_dependency = @sut.dependencies.first
          target_dependency.target.should == dependency_target
          container_proxy = target_dependency.target_proxy
          container_proxy.container_portal.should == @project.root_object.uuid
          container_proxy.proxy_type.should == '1'
          container_proxy.remote_global_id_string.should == dependency_target.uuid
          container_proxy.remote_info.should == dependency_target.name
        end

        it "doesn't duplicate dependencies" do
          dependency_target = @project.new_target(:static_library, 'Pods-SMCalloutView', :ios)
          @sut.add_dependency(dependency_target)
          @sut.add_dependency(dependency_target)
          @sut.dependencies.count.should == 1
        end
      end
    end


    #----------------------------------------#

    describe "Build phases" do
      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
        @sut.build_phases << @project.new(PBXCopyFilesBuildPhase)
        @sut.build_phases << @project.new(PBXShellScriptBuildPhase)
      end

      {
        :headers_build_phase       => PBXHeadersBuildPhase,
        :source_build_phase        => PBXSourcesBuildPhase,
        :frameworks_build_phase    => PBXFrameworksBuildPhase,
        :resources_build_phase     => PBXResourcesBuildPhase,
        :copy_files_build_phases   => PBXCopyFilesBuildPhase,
        :shell_script_build_phases => PBXShellScriptBuildPhase,
      }.each do |association_method, klass|

        it "returns an empty #{klass.isa}" do
          phase = @sut.send(association_method)
          if phase.is_a? Array
            phase = phase.first
          end

          phase.should.be.instance_of klass
          if phase.is_a? PBXFrameworksBuildPhase
            phase.files.count.should == 1
          else
            phase.files.to_a.should == []
          end
        end
      end

      it "returns the frameworks build phase" do
        @sut.frameworks_build_phases.class.should == PBXFrameworksBuildPhase
      end

      it "creates a new 'copy files build phase'" do
        before = @sut.copy_files_build_phases.count
        @sut.new_copy_files_build_phase
        @sut.copy_files_build_phases.count.should == before + 1
      end

      it "creates a new 'shell script build phase'" do
        before = @sut.shell_script_build_phases.count
        @sut.new_shell_script_build_phase
        @sut.shell_script_build_phases.count.should == before + 1
      end
    end

    #----------------------------------------#

    describe "System frameworks" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
        @sut.frameworks_build_phase.clear
        @project.frameworks_group.clear
      end

      describe "#add_system_framework" do

        it "adds a file reference for a system framework, in a dedicated subgroup of the Frameworks group" do
          @sut.add_system_framework('QuartzCore')
          file = @project['Frameworks/iOS'].files.first
          file.path.should == "Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk/System/Library/Frameworks/QuartzCore.framework"
          file.source_tree.should == 'DEVELOPER_DIR'
        end

        it "uses the sdk version of the target" do
          @sut.build_configuration_list.set_setting('SDKROOT', 'iphoneos6.0')
          @sut.add_system_framework('QuartzCore')
          file = @project['Frameworks/iOS'].files.first
          file.path.scan(/\d\.\d/).first.should == "6.0"
        end

        it "uses the last known SDK version if none is specified in the target" do
          @sut.build_configuration_list.set_setting('SDKROOT', 'iphoneos')
          @sut.add_system_framework('QuartzCore')
          file = @project['Frameworks/iOS'].files.first
          file.path.scan(/\d\.\d/).first.should == Xcodeproj::Constants::LAST_KNOWN_IOS_SDK
        end

        it "doesn't duplicate references to a frameworks if one already exists" do
          @sut.add_system_framework('QuartzCore')
          @sut.add_system_framework('QuartzCore')
          @project['Frameworks/iOS'].files.count.should == 1
        end

        it "adds the framework to the framework build phases" do
          @sut.add_system_framework('QuartzCore')
          @sut.frameworks_build_phase.file_display_names.should == ["QuartzCore.framework"]
        end

        it "doesn't duplicate the frameworks in the build phases" do
          @sut.add_system_framework('QuartzCore')
          @sut.add_system_framework('QuartzCore')
          @sut.frameworks_build_phase.files.count.should == 1
        end

        it "can add multiple frameworks" do
          @sut.add_system_frameworks(['CoreData', 'QuartzCore'])
          names = @sut.frameworks_build_phase.file_display_names
          names.should == ["CoreData.framework", "QuartzCore.framework"]
        end
      end

      #----------------------------------------#

      describe "#add_system_library" do

        it "adds a file reference for a system framework, to the Frameworks group" do
          @sut.add_system_library('xml')
          file = @project['Frameworks'].files.first
          file.path.should == "usr/lib/libxml.dylib"
          file.source_tree.should == 'SDKROOT'
        end

        it "doesn't duplicate references to a frameworks if one already exists" do
          @sut.add_system_library('xml')
          @sut.add_system_library('xml')
          @project.frameworks_group.files.count.should == 1
        end

        it "adds the framework to the framework build phases" do
          @sut.add_system_library('xml')
          @sut.frameworks_build_phase.file_display_names.should == ["libxml.dylib"]
        end

        it "doesn't duplicate the frameworks in the build phases" do
          @sut.add_system_library('xml')
          @sut.add_system_library('xml')
          @sut.frameworks_build_phase.files.count.should == 1
        end

        it "can add multiple libraries" do
          @sut.add_system_libraries(['z', 'xml'])
          names = @sut.frameworks_build_phase.file_display_names
          names.should == ["libz.dylib", "libxml.dylib"]
        end
      end

    end

    #----------------------------------------#

    describe "AbstractObject Hooks" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the pretty print representation" do
        pretty_print = @sut.pretty_print
        pretty_print['Pods']['Build Phases'].should == [
          { "SourcesBuildPhase" => [] },
          { "FrameworksBuildPhase" => ["Foundation.framework"] }
        ]
        build_configurations = pretty_print['Pods']['Build Configurations']
        build_configurations.map { |bf| bf.keys.first } .should == ["Release", "Debug"]
      end
    end
  end

  #---------------------------------------------------------------------------#


  describe PBXNativeTarget do

    describe "In general" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the product name, which is the name of the binary (minus prefix/suffix)" do
        @sut.name.should == "Pods"
        @sut.product_name.should == "Pods"
      end

      it "returns the product" do
        @sut.product_reference.should.be.instance_of PBXFileReference
        @sut.product_reference.path.should == "libPods.a"
      end

      it "returns that product type is a static library" do
        @sut.product_type.should == "com.apple.product-type.library.static"
      end

      it "returns an empty list of dependencies and build rules" do
        @sut.dependencies.to_a.should == []
        @sut.build_rules.to_a.should == []
      end

      describe "#sort" do

        it "can be sorted" do
          dep_2 = @project.new_target(:static_library, 'Dep_2', :ios)
          dep_1 = @project.new_target(:static_library, 'Dep_1', :ios)
          @sut.add_dependency(dep_2)
          @sut.add_dependency(dep_1)
          @sut.sort
          @sut.dependencies.map(&:display_name).should == ['Dep_1', 'Dep_2']
        end

        it "doesn't sort the build phases" do
          @sut.build_phases << @project.new(PBXSourcesBuildPhase)
          @sut.build_phases << @project.new(PBXHeadersBuildPhase)
          @sut.build_phases << @project.new(PBXSourcesBuildPhase)
          @sut.sort
          @sut.build_phases.map(&:isa).should == [
            "PBXSourcesBuildPhase",
            "PBXFrameworksBuildPhase",
            "PBXSourcesBuildPhase",
            "PBXHeadersBuildPhase",
            "PBXSourcesBuildPhase"
          ]
        end
      end
    end

    #----------------------------------------#

    describe "Helpers" do

      before do
        @sut = @project.new_target(:static_library, 'Pods', :ios)
      end

      it "returns the symbol type" do
        @sut.symbol_type.should == :static_library
      end

      it "adds a list of sources file to the target to the source build phase" do
        ref = @project.main_group.new_file('Class.m')
        @sut.add_file_references([ref], '-fobjc-arc')
        build_files = @sut.source_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Class.m'
        build_files.first.settings.should == {"COMPILER_FLAGS"=>"-fobjc-arc"}
      end

      it "adds a list of headers file to the target header build phases" do
        ref = @project.main_group.new_file('Class.h')
        @sut.add_file_references([ref], '-fobjc-arc')
        build_files = @sut.headers_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Class.h'
        build_files.first.settings.should.be.nil
      end

      it "adds a list of resources to the resources build phase" do
        ref = @project.main_group.new_file('Image.png')
        @sut.add_resources([ref])
        build_files = @sut.resources_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Image.png'
        build_files.first.settings.should.be.nil
      end

    end

  end

  #---------------------------------------------------------------------------#

end
