require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ProjectHelper do
    before do
      @helper = Xcodeproj::Project::ProjectHelper
    end

    #-------------------------------------------------------------------------#

    describe 'Targets' do
      it 'creates a new target' do
        target = @helper.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group, :objc)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.library.static'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)
        build_settings = configurations.first.build_settings
        build_settings['IPHONEOS_DEPLOYMENT_TARGET'].should == '6.0'
        build_settings['SDKROOT'].should == 'iphoneos'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).sort.should == %w(PBXFrameworksBuildPhase PBXSourcesBuildPhase)
      end

      it 'uses default build settings for Release and Debug configurations' do
        target = @helper.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group, :objc)
        debug_settings = @helper.common_build_settings(:debug, :ios, '6.0', :static_library)
        release_settings = @helper.common_build_settings(:release, :ios, '6.0', :static_library)

        target.build_settings('Debug').should == debug_settings
        target.build_settings('Release').should == release_settings
      end

      it 'uses build settings for Swift language if required' do
        target = @helper.new_target(@project, :framework, 'Pods', :ios, '8.0', @project.products_group, :objc)
        target.build_settings('Debug')['SWIFT_OPTIMIZATION_LEVEL'].should.be.nil

        target = @helper.new_target(@project, :framework, 'Pods', :ios, '8.0', @project.products_group, :swift)
        target.build_settings('Debug')['SWIFT_OPTIMIZATION_LEVEL'].should == '-Onone'
      end

      it 'creates a new resources bundle' do
        target = @helper.new_resources_bundle(@project, 'Pods', :ios, @project.products_group)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.bundle'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)
        build_settings = configurations.first.build_settings
        build_settings['SDKROOT'].should == 'iphoneos'
        build_settings['PRODUCT_NAME'].should == '$(TARGET_NAME)'
        build_settings['WRAPPER_EXTENSION'].should == 'bundle'
        build_settings['SKIP_INSTALL'].should == 'YES'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).sort.should == %w(PBXFrameworksBuildPhase PBXResourcesBuildPhase PBXSourcesBuildPhase)
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Frameworks' do
    end

    #-------------------------------------------------------------------------#

    describe '::common_build_settings' do
      it 'returns the build settings for an application by default' do
        settings = @helper.common_build_settings(:release, :ios, nil, nil)
        settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'].should == 'iPhone Developer'
      end

      it 'returns the build settings for an application' do
        settings = @helper.common_build_settings(:release, :ios, nil, Xcodeproj::Constants::PRODUCT_TYPE_UTI[:application])
        settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'].should == 'iPhone Developer'
      end

      it 'returns the build settings for a bundle' do
        settings = @helper.common_build_settings(:release, :osx, nil, Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        settings['COMBINE_HIDPI_IMAGES'].should == 'YES'
      end

      it 'returns a deep copy of the common build settings' do
        settings_1 = @helper.common_build_settings(:release, :ios, nil, nil)
        settings_2 = @helper.common_build_settings(:release, :ios, nil, nil)

        settings_1.object_id.should.not == settings_2.object_id
        settings_1['SDKROOT'].object_id.should.not == settings_2['SDKROOT'].object_id
        settings_1['SDKROOT'][1].object_id.should.not == settings_2['SDKROOT'][1].object_id
      end
    end

    #----------------------------------------#

    describe '::deep_dup' do
      it 'creates a copy of a given object' do
        object = 'String'
        copy = @helper.deep_dup(object)
        object.should == copy
        object.object_id.should.not == copy.object_id
      end

      it 'creates a deep copy of an array' do
        object = ['String']
        copy = @helper.deep_dup(object)
        object.should == copy
        object.object_id.should.not == copy.object_id
        object[1].object_id.should.not == copy.object_id[1]
      end

      it 'creates a deep copy of an array' do
        object = { :value => 'String' }
        copy = @helper.deep_dup(object)
        object.should == copy
        object.object_id.should.not == copy.object_id
        object.values[1].object_id.should.not == copy.values.object_id[1]
      end
    end

    #-------------------------------------------------------------------------#
  end
end
