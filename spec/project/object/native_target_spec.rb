require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe AbstractTarget do
    describe 'In general' do
      before do
        @target = @project.new_target(:static_library, 'Pods', :ios)
      end

      it 'returns the product name, which is the name of the binary (minus prefix/suffix)' do
        @target.name.should == 'Pods'
        @target.product_name.should == 'Pods'
      end
    end

    #----------------------------------------#

    describe 'Creation' do
      it 'inherits build configurations from the project similar to Xcode' do
        @project.add_build_configuration('App Store', :release)
        @target = @project.new_target(:static_library, 'Pods', :ios)

        @project.build_configurations.map(&:name).sort.should == \
          @target.build_configurations.map(&:name).sort
      end

      it 'uses default Release build configuration build settings for custom build configurations when adding a target' do
        @project.add_build_configuration('App Store', :release)
        target = @project.new_target(:static_library, 'Pods', :ios, '10.0', @project.products_group)

        release_settings = Xcodeproj::Project::ProjectHelper.common_build_settings(:release, :ios, '10.0', :static_library)
        target.build_settings('App Store').should == release_settings
      end
    end

    #----------------------------------------#

    describe 'Helpers' do
      before do
        @target = @project.new_target(:static_library, 'Pods', :ios)
      end

      describe '#common_resolved_build_setting' do
        it 'returns the resolved build setting for the given key as indicated in the target build configuration' do
          @project.build_configuration_list.set_setting('ARCHS', nil)
          @target.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @target.resolved_build_setting('ARCHS').should == { 'Release' => 'VALID_ARCHS', 'Debug' => 'VALID_ARCHS' }
        end

        it 'returns the resolved build setting for the given key as indicated in the project build configuration' do
          @project.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @target.build_configuration_list.set_setting('ARCHS', nil)
          @target.resolved_build_setting('ARCHS').should == { 'Release' => 'VALID_ARCHS', 'Debug' => 'VALID_ARCHS' }
        end

        it 'overrides the project settings with the target ones' do
          @project.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @target.build_configuration_list.set_setting('ARCHS', 'arm64')
          @target.resolved_build_setting('ARCHS').should == { 'Release' => 'arm64', 'Debug' => 'arm64' }
        end

        it 'returns the resolved build setting string value for a given key considering inheritance between project and target settings' do
          @project.build_configuration_list.set_setting('USER_DEFINED', 'PROJECT')
          @target.build_configuration_list.set_setting('USER_DEFINED', '$(inherited) TARGET')
          @target.resolved_build_setting('USER_DEFINED', true).should == { 'Release' => 'PROJECT TARGET', 'Debug' => 'PROJECT TARGET' }
        end

        it 'returns the resolved build setting array value for a given key considering inheritance between project and target settings' do
          @project.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(-framework Foundation))
          @target.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(${inherited} -framework CoreData))
          expected_value = %w(-framework Foundation -framework CoreData)
          @target.resolved_build_setting('OTHER_LDFLAGS', true).should == { 'Release' => expected_value, 'Debug' => expected_value }
        end

        it 'returns the resolved build setting array value for a given key considering inheritance between project and target settings when the target setting is a string' do
          @project.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(-framework Foundation))
          @target.build_configuration_list.set_setting('OTHER_LDFLAGS', '${inherited} -framework CoreData')
          expected_value = %w(-framework Foundation -framework CoreData)
          @target.resolved_build_setting('OTHER_LDFLAGS', true).should == { 'Release' => expected_value, 'Debug' => expected_value }
        end

        it 'returns the resolved build setting string value for a given key considering inherited between project, target and associated base configuration references' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @project.build_configuration_list.set_setting('USER_DEFINED', '$(inherited) PROJECT')
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.build_configuration_list.set_setting('USER_DEFINED', '$(inherited) TARGET')
          expected_value = 'PROJECT_XCCONFIG_VALUE PROJECT TARGET_XCCONFIG_VALUE TARGET'
          @target.resolved_build_setting('USER_DEFINED', true).should == { 'Release' => expected_value, 'Debug' => expected_value }
        end

        it 'returns the resolved build setting array value for a given key considering inherited between project, target and associated base configuration references' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @project.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(${inherited} -framework Foundation))
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(${inherited} -framework CoreData))
          expected_value = %w(-framework "UIKit" -framework Foundation -framework "CoreAnimation" -framework CoreData) # rubocop:disable Lint/PercentStringArray
          @target.resolved_build_setting('OTHER_LDFLAGS', true).should == { 'Release' => expected_value, 'Debug' => expected_value }
        end

        it 'returns the resolved build setting string value for a given key considering proper precedence between target and associated base configuration reference' do
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.build_configuration_list.set_setting('USER_DEFINED', 'TARGET')
          @target.resolved_build_setting('USER_DEFINED', true).should == { 'Release' => 'TARGET', 'Debug' => 'TARGET' }
        end

        it 'returns the resolved build setting array value for a given key considering proper precedence between target and associated base configuration reference' do
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(-framework CoreData))
          @target.resolved_build_setting('OTHER_LDFLAGS', true).should == { 'Release' => %w(-framework CoreData), 'Debug' => %w(-framework CoreData) }
        end

        it 'returns the resolved build setting string value for a given key considering proper precedence between project and associated base configuration reference' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @project.build_configuration_list.set_setting('USER_DEFINED', 'PROJECT')
          @target.resolved_build_setting('USER_DEFINED', true).should == { 'Release' => 'PROJECT', 'Debug' => 'PROJECT' }
        end

        it 'returns the resolved build setting array value for a given key considering proper precedence between project and associated base configuration reference' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @project.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(-framework CoreData))
          @target.build_configuration_list.set_setting('OTHER_LDFLAGS', %w(-framework UIKit))
          @target.resolved_build_setting('OTHER_LDFLAGS', true).should == { 'Release' => %w(-framework UIKit), 'Debug' => %w(-framework UIKit) }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution recursively' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @target.resolved_build_setting('PRODUCT_BUNDLE_IDENTIFIER', true).should == { 'Release' => 'com.cocoapods.app', 'Debug' => 'com.cocoapods.app.dev' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution appending' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @target.resolved_build_setting('CONFIG_APPEND', true).should == { 'Release' => 'PROJECT_XCCONFIG_VALUE_Release', 'Debug' => 'PROJECT_XCCONFIG_VALUE_Debug' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution in same level' do
          @target.build_configuration_list.set_setting('TARGET_USER_DEFINED', '${TARGET_USER_DEFINED_2}')
          @target.build_configuration_list.set_setting('TARGET_USER_DEFINED_2', 'TARGET_USER_DEFINED_VALUE')
          @target.resolved_build_setting('TARGET_USER_DEFINED', true).should == { 'Release' => 'TARGET_USER_DEFINED_VALUE', 'Debug' => 'TARGET_USER_DEFINED_VALUE' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @target.resolved_build_setting('DEVELOPMENT_TEAM', true).should == { 'Release' => 'PROJECT_XCCONFIG_VALUE', 'Debug' => 'PROJECT_XCCONFIG_VALUE' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: target xcconfig referencing target xcconfig' do
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          expected_value_release = 'User Defined xcconfig target Release'
          expected_value_debug = 'User Defined xcconfig target Debug'
          @target.resolved_build_setting('TARGET_REFERENCE_XCCONFIG_TARGET', true).should == { 'Release' => expected_value_release, 'Debug' => expected_value_debug }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: target xcconfig referencing target' do
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.build_configuration_list.set_setting('TARGET_USER_DEFINED', 'TARGET_USER_DEFINED_VALUE')
          @target.resolved_build_setting('TARGET_REFERENCE_TARGET', true).should == { 'Release' => 'TARGET_USER_DEFINED_VALUE', 'Debug' => 'TARGET_USER_DEFINED_VALUE' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: target xcconfig referencing project xcconfig' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          expected_value_debug = 'User Defined xcconfig project Debug'
          expected_value_release = 'User Defined xcconfig project Release'
          @target.resolved_build_setting('TARGET_REFERENCE_XCCONFIG_PROJECT', true).should == { 'Release' => expected_value_release, 'Debug' => expected_value_debug }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: target xcconfig referencing project' do
          @project.build_configuration_list.set_setting('PROJECT_USER_DEFINED', 'PROJECT_USER_DEFINED_VALUE')
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.resolved_build_setting('TARGET_REFERENCE_PROJECT', true).should == { 'Release' => 'PROJECT_USER_DEFINED_VALUE', 'Debug' => 'PROJECT_USER_DEFINED_VALUE' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: project xcconfig referencing project xcconfig' do
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          expected_value_release = 'User Defined xcconfig project Release'
          expected_value_debug = 'User Defined xcconfig project Debug'
          @target.resolved_build_setting('PROJECT_REFERENCE_XCCONFIG_PROJECT', true).should == { 'Release' => expected_value_release, 'Debug' => expected_value_debug }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: target xcconfig referencing project' do
          @project.build_configuration_list.set_setting('PROJECT_USER_DEFINED', 'PROJECT_USER_DEFINED_VALUE')
          project_xcconfig = @project.new_file(fixture_path('project.xcconfig'))
          @project.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = project_xcconfig }
          @target.resolved_build_setting('PROJECT_REFERENCE_PROJECT', true).should == { 'Release' => 'PROJECT_USER_DEFINED_VALUE', 'Debug' => 'PROJECT_USER_DEFINED_VALUE' }
        end

        it 'returns the resolved build setting string value for a given key considering variable substitution: project referencing target' do
          @project.build_configuration_list.set_setting('PROJECT_REFERENCE_TARGET', '$(TARGET_USER_DEFINED)')
          @target.build_configuration_list.set_setting('TARGET_USER_DEFINED', 'TARGET_USER_DEFINED_VALUE')
          @target.resolved_build_setting('PROJECT_REFERENCE_TARGET', true).should == { 'Release' => 'TARGET_USER_DEFINED_VALUE', 'Debug' => 'TARGET_USER_DEFINED_VALUE' }
        end

        it "returns the resolved build setting string value when a key is using variable substitution of it's own name" do
          @target.build_configuration_list.set_setting('A_BUILD_SETTING_WITH_VALUE', '$(A_BUILD_SETTING_WITH_VALUE)')
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.resolved_build_setting('A_BUILD_SETTING_WITH_VALUE', true).should == { 'Release' => 'Some value', 'Debug' => 'Some value' }
        end

        it 'returns the resolved build setting considering environment variables' do
          ENV['TARGET_REFERENCE_ENVIRONMENT'] = 'ENVIRONMENT_VARIABLE_VALUE'
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.resolved_build_setting('TARGET_REFERENCE_ENVIRONMENT', true).should == { 'Release' => 'ENVIRONMENT_VARIABLE_VALUE', 'Debug' => 'ENVIRONMENT_VARIABLE_VALUE' }
        end

        it 'returns the resolved build setting considering environment variables and variable substitution' do
          ENV['DEFINED_IN_ENVIRONMENT'] = 'ENVIRONMENT_VARIABLE_VALUE'
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          expected_value = { 'Release' => 'ENVIRONMENT_VARIABLE_VALUE', 'Debug' => 'ENVIRONMENT_VARIABLE_VALUE' }
          @target.resolved_build_setting('TARGET_REFERENCE_ENVIRONMENT_SUBSTITUTION', true).should == expected_value
        end
      end

      #----------------------------------------#

      describe '#common_resolved_build_setting' do
        it 'returns the common resolved build setting for the given key as indicated in the target build configuration' do
          @project.build_configuration_list.set_setting('ARCHS', nil)
          @target.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @target.common_resolved_build_setting('ARCHS').should == 'VALID_ARCHS'
        end

        it 'returns the common resolved build setting for the given key as indicated in the project build configuration' do
          @project.build_configuration_list.set_setting('ARCHS', 'VALID_ARCHS')
          @target.build_configuration_list.set_setting('ARCHS', nil)
          @target.common_resolved_build_setting('ARCHS').should == 'VALID_ARCHS'
        end

        it 'returns the common resolved build setting for the given key including xcconfig' do
          target_xcconfig = @project.new_file(fixture_path('target.xcconfig'))
          @target.build_configuration_list.build_configurations.each { |build_config| build_config.base_configuration_reference = target_xcconfig }
          @target.common_resolved_build_setting('APPLICATION_EXTENSION_API_ONLY', :resolve_against_xcconfig => false).should.be.nil
          @target.common_resolved_build_setting('APPLICATION_EXTENSION_API_ONLY', :resolve_against_xcconfig => true).should == 'YES'
        end

        it 'raises if the build setting has multiple values across the build configurations' do
          @target.build_configuration_list.build_configurations.first.build_settings['ARCHS'] = 'arm64'
          @target.build_configuration_list.build_configurations.last.build_settings['ARCHS'] = 'VALID_ARCHS'
          should.raise do
            @target.common_resolved_build_setting('ARCHS')
          end.message.should.match /multiple values/
        end

        it 'ignores nil values when determining if an unique value exists' do
          @target.build_configuration_list.build_configurations.first.build_settings['ARCHS'] = nil
          @target.build_configuration_list.build_configurations.last.build_settings['ARCHS'] = 'VALID_ARCHS'
          should.not.raise do
            @target.common_resolved_build_setting('ARCHS')
          end
        end
      end

      #----------------------------------------#

      it 'returns the SDK specified in its build configuration' do
        @project.build_configuration_list.set_setting('SDKROOT', nil)
        @target.build_configuration_list.set_setting('SDKROOT', 'iphoneos')
        @target.sdk.should == 'iphoneos'
      end

      it 'returns the SDK of the project if one is not specified in the build configurations' do
        @project.build_configuration_list.set_setting('SDKROOT', 'iphoneos')
        @target.build_configuration_list.set_setting('SDKROOT', nil)
        @target.sdk.should == 'iphoneos'
      end

      it 'returns the platform name' do
        @project.new_target(:static_library, 'Pods', :ios).platform_name.should == :ios
        @project.new_target(:static_library, 'Pods', :osx).platform_name.should == :osx
      end

      it 'returns the SDK version' do
        @project.new_target(:static_library, 'Pods', :ios).sdk_version.should.nil?
        @project.new_target(:static_library, 'Pods', :osx).sdk_version.should.nil?

        t1 = @project.new_target(:static_library, 'Pods', :ios)
        t1.build_configuration_list.set_setting('SDKROOT', 'iphoneos7.0')
        t1.sdk_version.should == '7.0'

        t2 = @project.new_target(:static_library, 'Pods', :osx)
        t2.build_configuration_list.set_setting('SDKROOT', 'macosx10.8')
        t2.sdk_version.should == '10.8'

        t3 = @project.new_target(:static_library, 'Pods', :watchos)
        t3.build_configuration_list.set_setting('SDKROOT', 'watchos2.0')
        t3.sdk_version.should == '2.0'

        t4 = @project.new_target(:static_library, 'Pods', :tvos)
        t4.build_configuration_list.set_setting('SDKROOT', 'tvos9.0')
        t4.sdk_version.should == '9.0'
      end

      describe 'returns the deployment target specified in its build configuration' do
        it 'works for iOS' do
          @project.build_configuration_list.set_setting('IPHONEOS_DEPLOYMENT_TARGET', nil)
          @project.new_target(:static_library, 'Pods', :ios, '4.3').deployment_target.should == '4.3'
        end

        it 'works for OSX' do
          @project.build_configuration_list.set_setting('MACOSX_DEPLOYMENT_TARGET', nil)
          @project.new_target(:static_library, 'Pods', :osx, '10.7').deployment_target.should == '10.7'
        end

        it 'works for tvOS' do
          @project.build_configuration_list.set_setting('TVOS_DEPLOYMENT_TARGET', nil)
          @project.new_target(:static_library, 'Pods', :tvos, '9.0').deployment_target.should == '9.0'
        end

        it 'works for watchOS' do
          @project.build_configuration_list.set_setting('WATCHOS_DEPLOYMENT_TARGET', nil)
          @project.new_target(:static_library, 'Pods', :watchos, '2.0').deployment_target.should == '2.0'
        end
      end

      describe 'returns the deployment target of the project build configuration' do
        it 'works for iOS' do
          @project.build_configuration_list.set_setting('IPHONEOS_DEPLOYMENT_TARGET', '4.3')
          ios_target = @project.new_target(:static_library, 'Pods', :ios)
          ios_target.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = nil
          ios_target.deployment_target.should == '4.3'
        end

        it 'works for OSX' do
          @project.build_configuration_list.set_setting('MACOSX_DEPLOYMENT_TARGET', '10.7')
          osx_target = @project.new_target(:static_library, 'Pods', :osx)
          osx_target.build_configurations.first.build_settings['MACOSX_DEPLOYMENT_TARGET'] = nil
          osx_target.deployment_target.should == '10.7'
        end

        it 'works for watchOS' do
          @project.build_configuration_list.set_setting('WATCHOS_DEPLOYMENT_TARGET', '2.0')
          watch_target = @project.new_target(:static_library, 'Pods', :watchos)
          watch_target.build_configurations.first.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = nil
          watch_target.deployment_target.should == '2.0'
        end

        it 'works for tvOS' do
          @project.build_configuration_list.set_setting('TVOS_DEPLOYMENT_TARGET', '9.0')
          tv_target = @project.new_target(:static_library, 'Pods', :tvos)
          tv_target.build_configurations.first.build_settings['TVOS_DEPLOYMENT_TARGET'] = nil
          tv_target.deployment_target.should == '9.0'
        end
      end

      describe 'sets the deployment target in its build configuration' do
        it 'works for iOS' do
          ios_target = @project.new_target(:static_library, 'Pods', :ios)
          ios_target.deployment_target = '8.4'
          ios_target.build_configurations.first.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].should == '8.4'
          ios_target.deployment_target.should == '8.4'
        end

        it 'works for OSX' do
          osx_target = @project.new_target(:static_library, 'Pods', :osx)
          osx_target.deployment_target = '10.10'
          osx_target.build_configurations.first.build_settings['MACOSX_DEPLOYMENT_TARGET'].should == '10.10'
          osx_target.deployment_target.should == '10.10'
        end

        it 'works for watchOS' do
          watch_target = @project.new_target(:static_library, 'Pods', :watchos)
          watch_target.deployment_target = '2.0'
          watch_target.build_configurations.first.build_settings['WATCHOS_DEPLOYMENT_TARGET'].should == '2.0'
          watch_target.deployment_target.should == '2.0'
        end

        it 'works for tvOS' do
          tv_target = @project.new_target(:static_library, 'Pods', :tvos)
          tv_target.deployment_target = '9.0'
          tv_target.build_configurations.first.build_settings['TVOS_DEPLOYMENT_TARGET'].should == '9.0'
          tv_target.deployment_target.should == '9.0'
        end
      end

      it 'returns the build configuration' do
        build_configurations = @target.build_configurations
        build_configurations.map(&:isa).uniq.should == ['XCBuildConfiguration']
        build_configurations.map(&:name).sort.should == %w(Debug Release)
      end

      #----------------------------------------#

      describe '#add_build_configuration' do
        it 'adds a new build configuration' do
          @target.add_build_configuration('App Store', :release)
          @target.build_configurations.map(&:name).sort.should == ['App Store', 'Debug', 'Release']
        end

        it "doesn't duplicate build configurations with existing names" do
          @target.add_build_configuration('App Store', :release)
          @target.add_build_configuration('App Store', :release)
          @target.build_configurations.map(&:name).grep('App Store').size.should == 1
        end

        it 'returns the new build configuration' do
          conf = @target.add_build_configuration('App Store', :release)
          conf.name.should == 'App Store'
        end

        it 'returns the existing build configuration' do
          conf_1 = @target.add_build_configuration('App Store', :release)
          conf_2 = @target.add_build_configuration('App Store', :release)
          conf_1.object_id.should == conf_2.object_id
        end

        it 'adds a new build configuration on an aggregate target' do
          aggregate_target = @project.new_aggregate_target('PBXAggregateTarget')
          aggregate_target.add_build_configuration('App Store', :release)
          aggregate_target.build_configurations.map(&:name).grep('App Store').size.should == 1
        end
      end

      #----------------------------------------#

      it 'returns the build settings of the configuration with the given name' do
        @target.build_settings('Debug')['SKIP_INSTALL'].should == 'YES'
      end

      describe '#add_dependency' do
        extend SpecHelper::TemporaryDirectory

        it 'adds a dependency on another target' do
          dependency_target = @project.new_target(:static_library, 'Pods-SMCalloutView', :ios)
          @target.add_dependency(dependency_target)
          @target.dependencies.count.should == 1
          target_dependency = @target.dependencies.first
          target_dependency.target.should == dependency_target
          container_proxy = target_dependency.target_proxy
          container_proxy.container_portal.should == @project.root_object.uuid
          container_proxy.proxy_type.should == '1'
          container_proxy.remote_global_id_string.should == dependency_target.uuid
          container_proxy.remote_info.should == dependency_target.name
        end

        it 'adds a dependency on a target in a subproject' do
          path = fixture_path('Sample Project/ReferencedProject/ReferencedProject.xcodeproj')
          subproject = Xcodeproj::Project.open(path)
          dependency_target = subproject.targets.first
          subproject_file_reference = @project.main_group.new_file(path)
          @target.add_dependency(dependency_target)

          @target.dependencies.count.should == 1
          target_dependency = @target.dependencies.first
          target_dependency.target.should.be.nil

          container_proxy = target_dependency.target_proxy
          container_proxy.container_portal.should == subproject_file_reference.uuid
          container_proxy.remote_global_id_string.should == dependency_target.uuid

          # Regression test: Ensure that we can open the modified project
          # without attempting to initialize an object with an unknown UUID
          Xcodeproj::UI.stubs(:warn).never
          temp_path = temporary_directory + 'ProjectWithTargetDependencyToSubproject.xcodeproj'
          @project.save(temp_path)
          Xcodeproj::Project.open(temp_path)
        end

        it "doesn't add a dependency on a target in an unknown project" do
          unknown_project = Xcodeproj::Project.new('/other_project_dir/OtherProject.xcodeproj')
          dependency_target = unknown_project.new_target(:static_library, 'Pods-SMCalloutView', :ios)

          should.raise ArgumentError do
            @target.add_dependency(dependency_target)
          end.message.should.match /not this project/
        end

        it "doesn't duplicate dependencies" do
          dependency_target = @project.new_target(:static_library, 'Pods-SMCalloutView', :ios)
          @target.add_dependency(dependency_target)
          @target.add_dependency(dependency_target)
          @target.dependencies.count.should == 1
        end

        it 'adds duplicate cross-dependencies' do
          group = @project.new_group('SubProjects')
          unknown_project1 = Xcodeproj::Project.new(temporary_directory + 'OtherProject1.xcodeproj')
          unknown_project2 = Xcodeproj::Project.new(temporary_directory + 'OtherProject2.xcodeproj')
          cross_target1 = unknown_project1.new_target(:static_library, 'SubTarget1', :ios)
          cross_target2 = unknown_project2.new_target(:static_library, 'SubTarget2', :ios)
          cross_target2.instance_variable_set(:@uuid, cross_target1.uuid)
          cross_target1.uuid.should == cross_target2.uuid
          unknown_project1.save
          unknown_project2.save
          group.new_file(unknown_project1.path)
          group.new_file(unknown_project2.path)
          @target.add_dependency(cross_target1)
          @target.add_dependency(cross_target2)
          @target.dependencies.count.should == 2
        end
      end

      describe '#dependency_for_target' do
        before do
          subproject_path = fixture_path('Sample Project/ReferencedProject/ReferencedProject.xcodeproj')
          @subproject = Xcodeproj::Project.open(subproject_path)

          project_path = fixture_path('Sample Project/ContainsSubproject/ContainsSubproject.xcodeproj')
          @project = Xcodeproj::Project.open(project_path)
        end

        it 'returns the dependency for targets from the current project' do
          @target = @project.targets.find { |t| t.name == 'ContainsSubprojectTests' }
          @target.dependency_for_target(@project.targets.first).should == @target.dependencies.first
        end

        it 'returns the dependency for targets from a subproject' do
          @target = @project.targets.first
          @target.dependency_for_target(@subproject.targets.first).should == @target.dependencies.first
        end
      end
    end

    #----------------------------------------#

    describe 'Build phases' do
      before do
        @target = @project.new_target(:static_library, 'Pods', :ios)
        @target.build_phases << @project.new(PBXCopyFilesBuildPhase)
        @target.build_phases << @project.new(PBXShellScriptBuildPhase)
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
          phase = @target.send(association_method)
          if phase.is_a? Array
            phase = phase.first
          end

          phase.should.be.instance_of klass
          phase.files.to_a.should == []
        end
      end

      it 'returns the frameworks build phase' do
        @target.frameworks_build_phases.class.should == PBXFrameworksBuildPhase
      end

      it "creates a new 'copy files build phase'" do
        before = @target.copy_files_build_phases.count
        @target.new_copy_files_build_phase
        @target.copy_files_build_phases.count.should == before + 1
      end

      it "creates a new 'shell script build phase'" do
        before = @target.shell_script_build_phases.count
        @target.new_shell_script_build_phase
        @target.shell_script_build_phases.count.should == before + 1
      end
    end

    #----------------------------------------#

    describe 'System frameworks' do
      before do
        @target = @project.new_target(:static_library, 'Pods', :ios)
        @target.frameworks_build_phase.clear
        @project.frameworks_group.clear
      end

      describe '#add_system_framework' do
        it 'adds a file reference for a system framework, in a dedicated subgroup of the Frameworks group' do
          @target.add_system_framework('QuartzCore')
          file = @project['Frameworks/iOS'].files.first
          file.path.should == 'Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.0.sdk/System/Library/Frameworks/QuartzCore.framework'
          file.source_tree.should == 'DEVELOPER_DIR'
        end

        it 'uses the sdk version of the target' do
          @target.build_configuration_list.set_setting('SDKROOT', 'iphoneos6.0')
          @target.add_system_framework('QuartzCore')
          file = @project['Frameworks/iOS'].files.first
          file.path.scan(/\d\.\d/).first.should == '6.0'
        end

        it 'uses the last known SDK version if none is specified in the target' do
          @target.build_configuration_list.set_setting('SDKROOT', 'iphoneos')
          @target.add_system_framework('QuartzCore')
          file = @project['Frameworks/iOS'].files.first
          file.path.scan(/\d\d\.\d/).first.should == Xcodeproj::Constants::LAST_KNOWN_IOS_SDK
        end

        it 'uses the last known tvOS SDK version if none is specified in the target' do
          @target.build_configuration_list.set_setting('SDKROOT', 'appletvos')
          @target.add_system_framework('TVServices')
          file = @project['Frameworks/tvOS'].files.first
          file.path.scan(/\d\d\.\d/).first.should == Xcodeproj::Constants::LAST_KNOWN_TVOS_SDK
        end

        it 'uses the last known watchOS SDK version if none is specified in the target' do
          @target.build_configuration_list.set_setting('SDKROOT', 'watchos')
          @target.add_system_framework('WatchConnectivity')
          file = @project['Frameworks/watchOS'].files.first
          file.path.scan(/\d\.\d/).first.should == Xcodeproj::Constants::LAST_KNOWN_WATCHOS_SDK
        end

        it "doesn't duplicate references to a frameworks if one already exists" do
          @target.add_system_framework('QuartzCore')
          @target.add_system_framework('QuartzCore')
          @project['Frameworks/iOS'].files.count.should == 1
        end

        it 'adds the framework to the framework build phases' do
          @target.add_system_framework('QuartzCore')
          @target.frameworks_build_phase.file_display_names.should == ['QuartzCore.framework']
        end

        it "doesn't duplicate the frameworks in the build phases" do
          @target.add_system_framework('QuartzCore')
          @target.add_system_framework('QuartzCore')
          @target.frameworks_build_phase.files.count.should == 1
        end

        it 'can add multiple frameworks' do
          @target.add_system_frameworks(%w(CoreData QuartzCore))
          names = @target.frameworks_build_phase.file_display_names
          names.should == ['CoreData.framework', 'QuartzCore.framework']
        end

        it 'returns the newly created file references' do
          references = @target.add_system_frameworks(%w(CoreData QuartzCore))
          references.map(&:display_name).should == ['CoreData.framework', 'QuartzCore.framework']
        end
      end

      #----------------------------------------#

      describe '#add_system_library' do
        it 'adds a file reference for a system framework, to the Frameworks group' do
          @target.add_system_library('xml')
          file = @project['Frameworks'].files.first
          file.path.should == 'usr/lib/libxml.dylib'
          file.source_tree.should == 'SDKROOT'
        end

        it "doesn't duplicate references to a frameworks if one already exists" do
          @target.add_system_library('xml')
          @target.add_system_library('xml')
          @project.frameworks_group.files.count.should == 1
        end

        it 'adds the framework to the framework build phases' do
          @target.add_system_library('xml')
          @target.frameworks_build_phase.file_display_names.should == ['libxml.dylib']
        end

        it "doesn't duplicate the frameworks in the build phases" do
          @target.add_system_library('xml')
          @target.add_system_library('xml')
          @target.frameworks_build_phase.files.count.should == 1
        end

        it 'can add multiple libraries' do
          @target.add_system_libraries(%w(z xml))
          names = @target.frameworks_build_phase.file_display_names
          names.should == ['libz.dylib', 'libxml.dylib']
        end
      end

      #----------------------------------------#

      describe '#add_system_library_tbd' do
        it 'adds a file reference for a system framework, to the Frameworks group' do
          @target.add_system_library_tbd('xml')
          file = @project['Frameworks'].files.first
          file.path.should == 'usr/lib/libxml.tbd'
          file.source_tree.should == 'SDKROOT'
        end

        it "doesn't duplicate references to a frameworks if one already exists" do
          @target.add_system_library_tbd('xml')
          @target.add_system_library_tbd('xml')
          @project.frameworks_group.files.count.should == 1
        end

        it 'adds the framework to the framework build phases' do
          @target.add_system_library_tbd('xml')
          @target.frameworks_build_phase.file_display_names.should == ['libxml.tbd']
        end

        it "doesn't duplicate the frameworks in the build phases" do
          @target.add_system_library_tbd('xml')
          @target.add_system_library_tbd('xml')
          @target.frameworks_build_phase.files.count.should == 1
        end

        it 'can add multiple libraries' do
          @target.add_system_libraries_tbd(%w(z xml))
          names = @target.frameworks_build_phase.file_display_names
          names.should == ['libz.tbd', 'libxml.tbd']
        end
      end
    end

    #----------------------------------------#

    describe 'AbstractObject Hooks' do
      before do
        @target = @project.new_target(:framework, 'Pods', :ios)
      end

      it 'returns the pretty print representation' do
        pretty_print = @target.pretty_print
        pretty_print['Pods']['Build Phases'].should == [
          { 'Headers' => [] },
          { 'Sources' => [] },
          { 'Frameworks' => ['Foundation.framework'] },
          { 'Resources' => [] },
        ]
        build_configurations = pretty_print['Pods']['Build Configurations']
        build_configurations.map { |bf| bf.keys.first } .should == %w(Release Debug)
      end
    end
  end

  #---------------------------------------------------------------------------#

  describe PBXNativeTarget do
    describe 'In general' do
      before do
        @target = @project.new_target(:static_library, 'Pods', :ios)
      end

      it 'returns the product name, which is the name of the binary (minus prefix/suffix)' do
        @target.name.should == 'Pods'
        @target.product_name.should == 'Pods'
      end

      it 'returns the product' do
        @target.product_reference.should.be.instance_of PBXFileReference
        @target.product_reference.path.should == 'libPods.a'
      end

      it 'returns that product type is a static library' do
        @target.product_type.should == 'com.apple.product-type.library.static'
      end

      it 'returns an empty list of dependencies and build rules' do
        @target.dependencies.to_a.should == []
        @target.build_rules.to_a.should == []
      end

      describe '#sort' do
        it 'can be sorted' do
          dep_2 = @project.new_target(:static_library, 'Dep_2', :ios)
          dep_1 = @project.new_target(:static_library, 'Dep_1', :ios)
          @target.add_dependency(dep_2)
          @target.add_dependency(dep_1)
          @target.sort
          @target.dependencies.map(&:display_name).should == %w(Dep_1 Dep_2)
        end

        it "doesn't sort the build phases" do
          @target.build_phases << @project.new(PBXSourcesBuildPhase)
          @target.build_phases << @project.new(PBXHeadersBuildPhase)
          @target.build_phases << @project.new(PBXSourcesBuildPhase)
          @target.sort
          @target.build_phases.map(&:isa).should == %w(PBXHeadersBuildPhase PBXSourcesBuildPhase PBXFrameworksBuildPhase PBXSourcesBuildPhase PBXHeadersBuildPhase PBXSourcesBuildPhase)
        end
      end

      describe '#to_hash_as' do
        it "does not include package product dependencies in its hash if there aren't any" do
          @target.to_hash_as['packageProductDependencies'].should.be.nil
        end

        it 'include package product dependencies in its hash if it contains at least one' do
          @target.package_product_dependencies << XCSwiftPackageProductDependency.new(@project, 'uuid')
          @target.to_hash_as['packageProductDependencies'].should == ['uuid']
        end
      end

      describe '#to_ascii_plist' do
        it "does not include package product dependencies in its plist if there aren't any" do
          @target.to_ascii_plist.value['packageProductDependencies'].should.be.nil
        end

        it 'include package product dependencies in its plist if it contains at least one' do
          @target.package_product_dependencies << XCSwiftPackageProductDependency.new(@project, 'uuid1')
          @target.package_product_dependencies << XCSwiftPackageProductDependency.new(@project, 'uuid2')
          @target.to_ascii_plist.value['packageProductDependencies'].should == [
            Nanaimo::String.new('uuid1', ' SwiftPackageProductDependency '),
            Nanaimo::String.new('uuid2', ' SwiftPackageProductDependency '),
          ]
        end
      end
    end

    #----------------------------------------#

    describe 'Helpers' do
      before do
        @target = @project.new_target(:static_library, 'Pods', :ios)
      end

      describe '#symbol_type' do
        it 'returns the symbol type' do
          @target.symbol_type.should == :static_library
        end

        it 'returns nil if the product type is unknown' do
          @target.stubs(:product_type => 'com.apple.product-type.new-stuff')
          @target.symbol_type.should.be.nil?
        end
      end

      describe '#test_target_type?' do
        it 'returns true for test target types' do
          @target.stubs(:symbol_type => :octest_bundle)
          @target.should.be.test_target_type

          @target.stubs(:symbol_type => :unit_test_bundle)
          @target.should.be.test_target_type

          @target.stubs(:symbol_type => :ui_test_bundle)
          @target.should.be.test_target_type
        end

        it 'returns false for non-test target types' do
          @target.stubs(:symbol_type => :application)
          @target.should.not.be.test_target_type
        end
      end

      describe '#launchable_target_type?' do
        it 'returns true for command line tools and applications' do
          @target.stubs(:symbol_type => :application)
          @target.should.be.launchable_target_type?

          @target.stubs(:symbol_type => :command_line_tool)
          @target.should.be.launchable_target_type?
        end

        it 'returns false for non launchable types' do
          @target.stubs(:symbol_type => :octest_bundle)
          @target.should.not.be.launchable_target_type?

          @target.stubs(:symbol_type => :unit_test_bundle)
          @target.should.not.be.launchable_target_type?

          @target.stubs(:symbol_type => :ui_test_bundle)
          @target.should.not.be.launchable_target_type?
        end
      end

      describe '#extension_target_type?' do
        it 'returns true for extension target types' do
          @target.stubs(:symbol_type => :app_extension)
          @target.should.be.extension_target_type

          @target.stubs(:symbol_type => :watch_extension)
          @target.should.be.extension_target_type

          @target.stubs(:symbol_type => :watch2_extension)
          @target.should.be.extension_target_type

          @target.stubs(:symbol_type => :tv_extension)
          @target.should.be.extension_target_type

          @target.stubs(:symbol_type => :messages_extension)
          @target.should.be.extension_target_type
        end

        it 'returns false for non-extension target types' do
          @target.stubs(:symbol_type => :application)
          @target.should.not.be.extension_target_type

          @target.stubs(:symbol_type => :messages_application)
          @target.should.not.be.extension_target_type
        end
      end

      it 'adds a list of source files to the target to the source build phase' do
        ref = @project.main_group.new_file('Class.m')
        @target.add_file_references([ref], '-fobjc-arc')
        build_files = @target.source_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Class.m'
        build_files.first.settings.should == { 'COMPILER_FLAGS' => '-fobjc-arc' }
      end

      it 'adds a list of header files to the target header build phases' do
        ref = @project.main_group.new_file('Class.h')
        @target.add_file_references([ref], '-fobjc-arc')
        build_files = @target.headers_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Class.h'
        build_files.first.settings.should.be.nil
      end

      it 'adds a list of header files with capitalized .H extension to the target header build phases' do
        ref = @project.main_group.new_file('CLASS.H')
        @target.add_file_references([ref], '-fobjc-arc')
        build_files = @target.headers_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'CLASS.H'
        build_files.first.settings.should.be.nil
      end

      it 'returns a list of header files to the target header build phases' do
        ref = @project.main_group.new_file('Class.h')
        new_build_files = @target.add_file_references([ref], '-fobjc-arc')
        build_files = @target.headers_build_phase.files
        new_build_files.should == build_files
      end

      it 'yields a list of header files to the target header build phases' do
        ref = @project.main_group.new_file('Class.h')
        build_files = @target.add_file_references([ref], '-fobjc-arc') do |build_file|
          build_file.should.be.an.instance_of?(PBXBuildFile)
          build_file.settings = { 'ATTRIBUTES' => ['Public'] }
        end
        build_files.first.settings.should == { 'ATTRIBUTES' => ['Public'] }
      end

      it 'adds a list of resources to the resources build phase' do
        ref = @project.main_group.new_file('Image.png')
        @target.add_resources([ref])
        build_files = @target.resources_build_phase.files
        build_files.count.should == 1
        build_files.first.file_ref.path.should == 'Image.png'
        build_files.first.settings.should.be.nil
      end

      it 'de-duplicates added sources files' do
        ref = @project.main_group.new_file('Class.h')
        new_build_files = @target.add_file_references([ref], '-fobjc-arc')
        @target.add_file_references([ref], '-fobjc-arc')
        build_files = @target.headers_build_phase.files
        new_build_files.should == build_files
      end

      it 'de-duplicates added resources' do
        ref = @project.main_group.new_file('Image.png')
        @target.add_resources([ref])
        @target.add_resources([ref])
        build_files = @target.resources_build_phase.files
        build_files.count.should == 1
      end
    end
  end

  #---------------------------------------------------------------------------#
end
