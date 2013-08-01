require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ProjectHelper do

    describe "Targets" do

      it "creates a new target" do
        target = Xcodeproj::Project::ProjectHelper.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group)
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
        target = Xcodeproj::Project::ProjectHelper.new_resources_bundle(@project, 'Pods', :ios, @project.products_group)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.bundle'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w| Debug Release |
        build_settings = configurations.first.build_settings
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
      it "adds a file reference for a system framework, to the Frameworks group" do
        target = stub(:sdk => 'iphoneos5.0')
        file = Xcodeproj::Project::ProjectHelper.add_system_framework(@project, 'QuartzCore', target)
        file.group.should == @project['Frameworks']
        file.name.should == 'QuartzCore.framework'
        file.path.should.match %r|Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/System/Library/Frameworks/QuartzCore.framework|
        file.source_tree.should == 'DEVELOPER_DIR'
      end

      it "links system frameworks to the last known SDK if needed" do
        target = stub(:sdk => 'iphoneos')
        file = Xcodeproj::Project::ProjectHelper.add_system_framework(@project, 'QuartzCore', target)
        file.path.should.match %r|Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.*.sdk/System/Library/Frameworks/QuartzCore.framework|
        file.source_tree.should == 'DEVELOPER_DIR'
      end

      it "does not add a system framework if it already exists in the project" do
        target = stub(:sdk => 'iphoneos6.0')
        file_1 = Xcodeproj::Project::ProjectHelper.add_system_framework(@project, 'Foundation', target)
        file_1.name.should == 'Foundation.framework'
        before_size = @project.frameworks_group.files.size
        file_2 = Xcodeproj::Project::ProjectHelper.add_system_framework(@project, 'Foundation', target)
        file_2.should == file_1
        @project.frameworks_group.files.size.should == before_size
      end
    end

    #-------------------------------------------------------------------------#

  end
end
