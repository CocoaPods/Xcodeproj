require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ProjectHelper do

    before do
      @sut = Xcodeproj::Project::ProjectHelper
      Xcodeproj::XcodebuildHelper.any_instance.stubs(:last_ios_sdk).returns(Xcodeproj::Constants::LAST_KNOWN_IOS_SDK)
    end

    #-------------------------------------------------------------------------#

    describe "Targets" do

      it "creates a new target" do
        target = @sut.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.library.static'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w| Debug Release |
        build_settings = configurations.first.build_settings
        build_settings['IPHONEOS_DEPLOYMENT_TARGET'].should == '6.0'
        build_settings['SDKROOT'].should == 'iphoneos'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).sort.should == [
          "PBXFrameworksBuildPhase",
          "PBXSourcesBuildPhase",
        ]
      end

      it "creates a new resources bundle" do
        target = @sut.new_resources_bundle(@project, 'Pods', :ios, @project.products_group)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.bundle'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w| Debug Release |
        build_settings = configurations.first.build_settings
        build_settings['SDKROOT'].should == 'iphoneos'
        build_settings['PRODUCT_NAME'].should == '$(TARGET_NAME)'
        build_settings['WRAPPER_EXTENSION'].should == 'bundle'
        build_settings['SKIP_INSTALL'].should == 'YES'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).sort.should == [
          "PBXFrameworksBuildPhase",
          "PBXResourcesBuildPhase",
          "PBXSourcesBuildPhase",
        ]
      end
    end

    #-------------------------------------------------------------------------#

    describe "System Frameworks" do

      before do
        @target = @sut.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group)
      end

      it "adds a file reference for a system framework, to the Frameworks group" do
        @target.stubs(:sdk).returns('iphoneos5.0')
        file = @sut.add_system_framework(@project, 'QuartzCore', @target)
        file.parent.should == @project['Frameworks']
        file.name.should == 'QuartzCore.framework'
        file.path.should.match %r|Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/System/Library/Frameworks/QuartzCore.framework|
        file.source_tree.should == 'DEVELOPER_DIR'
      end

      it "links system frameworks to the last known SDK if needed" do
        @target.stubs(:sdk).returns('iphoneos')
        file = @sut.add_system_framework(@project, 'QuartzCore', @target)
        file.path.should.match %r|Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.*.sdk/System/Library/Frameworks/QuartzCore.framework|
        file.source_tree.should == 'DEVELOPER_DIR'
      end

      it "does not add a system framework if it already exists in the project" do
        file_1 = @sut.add_system_framework(@project, 'Foundation', @target)
        file_1.name.should == 'Foundation.framework'
        before_size = @project.frameworks_group.files.size
        file_2 = @sut.add_system_framework(@project, 'Foundation', @target)
        file_2.should == file_1
        @project.frameworks_group.files.size.should == before_size
      end

      it "adds the framework to the framework build phase of the target" do
        ref = @sut.add_system_framework(@project, 'QuartzCore', @target)
        @target.frameworks_build_phase.files_references.should.include(ref)
      end
    end

    #-------------------------------------------------------------------------#

    describe "::common_build_settings" do

      it "returns the build settings for an application by default" do
        settings = @sut.common_build_settings(:release, :ios, nil, nil)
        settings['OTHER_CFLAGS'].should == ['-DNS_BLOCK_ASSERTIONS=1', "$(inherited)"]
      end

      it "returns the build settings for an application" do
        settings = @sut.common_build_settings(:release, :ios, nil, Xcodeproj::Constants::PRODUCT_TYPE_UTI[:application])
        settings['OTHER_CFLAGS'].should == ['-DNS_BLOCK_ASSERTIONS=1', "$(inherited)"]
      end


      it "returns the build settings for an application" do
        settings = @sut.common_build_settings(:release, :osx, nil, Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        settings['COMBINE_HIDPI_IMAGES'].should == 'YES'
      end

    end

    #-------------------------------------------------------------------------#

  end
end
