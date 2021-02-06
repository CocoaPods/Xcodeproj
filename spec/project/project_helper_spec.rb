require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ProjectHelper do
    before do
      @helper = Xcodeproj::Project::ProjectHelper
    end

    #-------------------------------------------------------------------------#

    describe 'Targets' do
      it 'creates a new target' do
        target = @helper.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group, :objc, nil)
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

        target.build_phases.map(&:isa).should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase)
      end

      it 'creates a new tvOS target' do
        target = @helper.new_target(@project, :static_library, 'Pods', :tvos, '9.0', @project.products_group, :objc, nil)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.library.static'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)
        build_settings = configurations.first.build_settings
        build_settings['TVOS_DEPLOYMENT_TARGET'].should == '9.0'
        build_settings['SDKROOT'].should == 'appletvos'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase)
      end

      it 'creates a new watchOS target' do
        target = @helper.new_target(@project, :static_library, 'Pods', :watchos, '2.0', @project.products_group, :objc, nil)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.library.static'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)
        build_settings = configurations.first.build_settings
        build_settings['WATCHOS_DEPLOYMENT_TARGET'].should == '2.0'
        build_settings['SDKROOT'].should == 'watchos'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase)
      end

      it 'uses default build settings for Release and Debug configurations' do
        target = @helper.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group, :objc, nil)
        debug_settings = @helper.common_build_settings(:debug, :ios, '6.0', :static_library)
        release_settings = @helper.common_build_settings(:release, :ios, '6.0', :static_library)

        target.build_settings('Debug').should == debug_settings
        target.build_settings('Release').should == release_settings
      end

      it 'uses default build settings for custom build configurations' do
        @project.add_build_configuration('Foo', :release)
        @project.add_build_configuration('Bar', :debug)
        target = @helper.new_target(@project, :static_library, 'Pods', :ios, '6.0', @project.products_group, :objc, nil)
        debug_settings = @helper.common_build_settings(:debug, :ios, '6.0', :static_library)
        release_settings = @helper.common_build_settings(:release, :ios, '6.0', :static_library)

        target.build_settings('Bar').should == debug_settings
        target.build_settings('Foo').should == release_settings
      end

      it 'creates a new resources bundle' do
        target = @helper.new_resources_bundle(@project, 'Pods', :ios, @project.products_group, nil)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.bundle'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)
        configurations[0].build_settings.should.not.equal? configurations[1].build_settings

        build_settings = configurations.first.build_settings
        build_settings['SDKROOT'].should == 'iphoneos'
        build_settings['WRAPPER_EXTENSION'].should == 'bundle'
        build_settings['SKIP_INSTALL'].should == 'YES'

        @project.targets.should.include target
        @project.products.should.include target.product_reference

        target.build_phases.map(&:isa).should == %w(PBXSourcesBuildPhase PBXFrameworksBuildPhase PBXResourcesBuildPhase)
      end

      it 'creates a new aggregate target' do
        target = @helper.new_aggregate_target(@project, 'Pods', :ios, '9.0')
        target.name.should == 'Pods'
        target.product_name.should.be.nil

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)

        build_settings = configurations.first.build_settings
        build_settings['SDKROOT'].should == 'iphoneos'
        build_settings['IPHONEOS_DEPLOYMENT_TARGET'].should == '9.0'

        @project.targets.should.include target

        target.build_phases.should.be.empty
      end

      it 'creates a new legacy target' do
        target = @helper.new_legacy_target(@project, 'Pods')
        target.name.should == 'Pods'
        target.build_tool_path.should == '/usr/bin/make'
        target.build_arguments_string.should == '$(ACTION)'
        target.build_working_directory.should.be.nil
        target.pass_build_settings_in_environment.should == '1'

        target.build_configuration_list.should.not.be.nil
        configurations = target.build_configuration_list.build_configurations
        configurations.map(&:name).sort.should == %w(Debug Release)

        @project.targets.should.include target

        target.build_phases.should.be.empty
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Frameworks' do
    end

    #-------------------------------------------------------------------------#

    describe '::common_build_settings' do
      it 'returns the build settings for an application by default' do
        settings = @helper.common_build_settings(:release, :ios, nil, nil)
        settings['ASSETCATALOG_COMPILER_APPICON_NAME'].should == 'AppIcon'
      end

      it 'returns the build settings for an application' do
        settings = @helper.common_build_settings(:release, :ios, nil, Xcodeproj::Constants::PRODUCT_TYPE_UTI[:application])
        settings['ASSETCATALOG_COMPILER_APPICON_NAME'].should == 'AppIcon'
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

      it 'sets CLANG_ENABLE_OBJC_WEAK=NO for old deployment targets' do
        settings = @helper.common_build_settings(:release, :osx, '10.6', Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        settings['CLANG_ENABLE_OBJC_WEAK'].should == 'NO'
        settings = @helper.common_build_settings(:release, :osx, '10.7', Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        settings.should.not.key 'CLANG_ENABLE_OBJC_WEAK'

        settings = @helper.common_build_settings(:release, :ios, '4.3', Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        settings['CLANG_ENABLE_OBJC_WEAK'].should == 'NO'
        settings = @helper.common_build_settings(:release, :ios, '5', Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        settings.should.not.key 'CLANG_ENABLE_OBJC_WEAK'
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

    describe '::build_phases_for_target_type' do
      it 'excludes resources for libraries' do
        @helper.build_phases_for_target_type(:static_library).
          should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase)
        @helper.build_phases_for_target_type(:dynamic_library).
          should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase)
      end

      it 'includes resources for frameworks' do
        @helper.build_phases_for_target_type(:framework).
          should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase PBXResourcesBuildPhase)
      end

      it 'excludes headers by default' do
        @helper.build_phases_for_target_type(:unknown).
          should == %w(PBXSourcesBuildPhase PBXFrameworksBuildPhase PBXResourcesBuildPhase)
      end

      it 'only contains sources and frameworks for CLIs' do
        @helper.build_phases_for_target_type(:command_line_tool).
          should == %w(PBXSourcesBuildPhase PBXFrameworksBuildPhase)
      end
    end

    #-------------------------------------------------------------------------#
  end
end
