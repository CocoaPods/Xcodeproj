require File.expand_path('../spec_helper', __FILE__)

def compare_elements(a, b)
  return a.should.be.nil if b.nil?
  a.attributes.should.be.equal b.attributes
  a.elements.count.should.be.equal b.elements.count
end

module ProjectSpecs
  describe Xcodeproj::XCScheme do
    before do
      @project.stubs(:path).returns(Pathname.new('path/Cocoa Application.xcodeproj'))
      @project.stubs(:project_dir).returns(Pathname.new('path/'))
    end

    #-------------------------------------------------------------------------#

    describe 'Load an existing scheme from file' do
      before do
        scheme_path = fixture_path('SharedSchemes', 'SharedSchemes.xcodeproj/xcshareddata/xcschemes/SharedSchemes.xcscheme')
        @scheme = Xcodeproj::XCScheme.new(scheme_path)
      end

      extend SpecHelper::XCScheme
      scheme_actions = %i(build_action test_action profile_action archive_action)
      check_load_pre_and_post_actions_from_file(scheme_actions)

      it 'Properly map the scheme\'s BuildAction' do
        @scheme.build_action.run_post_actions_on_failure?.should == true
        @scheme.build_action.parallelize_buildables?.should == true
        @scheme.build_action.build_implicit_dependencies?.should == true
        @scheme.build_action.entries.count.should == 1

        entry = @scheme.build_action.entries[0]
        entry.class.should == Xcodeproj::XCScheme::BuildAction::Entry
        entry.build_for_testing?.should == true
        entry.build_for_running?.should == true
        entry.build_for_profiling?.should == true
        entry.build_for_archiving?.should == true
        entry.build_for_analyzing?.should == true

        entry.buildable_references.count.should == 1
        ref = entry.buildable_references[0]
        ref.target_name.should == 'SharedSchemes'
        ref.target_uuid.should == '632143E8175736EE0038D40D'
        ref.buildable_name.should == 'SharedSchemes.app'
        ref.target_referenced_container.should == 'container:SharedSchemes.xcodeproj'
      end

      it 'Properly map the scheme\'s TestAction' do
        @scheme.test_action.should_use_launch_scheme_args_env?.should == true
        @scheme.test_action.build_configuration.should == 'Debug'
        @scheme.test_action.disable_main_thread_checker?.should == true

        @scheme.test_action.testables.count.should == 0
        @scheme.test_action.macro_expansions.count.should == 1

        macro = @scheme.test_action.macro_expansions[0]
        macro.class.should == Xcodeproj::XCScheme::MacroExpansion

        ref = macro.buildable_reference
        ref.target_name.should == 'SharedSchemes'
        ref.target_uuid.should == '632143E8175736EE0038D40D'
        ref.buildable_name.should == 'SharedSchemes.app'
        ref.target_referenced_container.should == 'container:SharedSchemes.xcodeproj'

        @scheme.test_action.environment_variables.to_a.should ==
          [{ :key => 'testkey', :value => 'testval', :enabled => true },
           { :key => 'testkeydisabled', :value => 'testvaldisabled', :enabled => false }]
      end

      it 'Properly map the scheme\'s LaunchAction' do
        @scheme.launch_action.allow_location_simulation?.should == true
        @scheme.launch_action.build_configuration.should == 'Debug'
        @scheme.launch_action.disable_main_thread_checker?.should == true
        @scheme.launch_action.stop_on_every_main_thread_checker_issue?.should == true

        bpr = @scheme.launch_action.buildable_product_runnable
        bpr.class.should == Xcodeproj::XCScheme::BuildableProductRunnable

        ref = bpr.buildable_reference
        ref.target_name.should == 'SharedSchemes'
        ref.target_uuid.should == '632143E8175736EE0038D40D'
        ref.buildable_name.should == 'SharedSchemes.app'
        ref.target_referenced_container.should == 'container:SharedSchemes.xcodeproj'

        @scheme.launch_action.environment_variables.to_a.should ==
          [{ :key => 'launchkey', :value => 'launchval', :enabled => true },
           { :key => 'launchkeydisabled', :value => 'launchvaldisabled', :enabled => false }]
      end

      it 'Properly map the scheme\'s ProfileAction' do
        @scheme.profile_action.should_use_launch_scheme_args_env?.should == true
        @scheme.profile_action.build_configuration.should == 'Release'

        bpr = @scheme.launch_action.buildable_product_runnable
        bpr.class.should == Xcodeproj::XCScheme::BuildableProductRunnable

        ref = bpr.buildable_reference
        ref.target_name.should == 'SharedSchemes'
        ref.target_uuid.should == '632143E8175736EE0038D40D'
        ref.buildable_name.should == 'SharedSchemes.app'
        ref.target_referenced_container.should == 'container:SharedSchemes.xcodeproj'
      end

      it 'Properly map the scheme\'s AnalyzeAction' do
        @scheme.analyze_action.build_configuration.should == 'Debug'
      end

      it 'Properly map the scheme\'s ArchiveAction' do
        @scheme.archive_action.build_configuration.should == 'Release'
        @scheme.archive_action.reveal_archive_in_organizer?.should == true
      end
    end

    describe 'Configuration' do
      it 'app target for launching' do
        app = @project.new_target(:application, 'App', :ios)
        scheme = Xcodeproj::XCScheme.new
        scheme.configure_with_targets(app, nil, :launch_target => true)
        scheme.build_action.entries.count.should == 1

        entry = scheme.build_action.entries[0]

        entry.build_for_running?.should == true
        entry.build_for_testing?.should == true
        entry.build_for_profiling?.should == true
        entry.build_for_archiving?.should == true
        entry.build_for_analyzing?.should == true
        entry.buildable_references.first.buildable_name.should == 'App.app'

        scheme.launch_action.buildable_product_runnable.buildable_reference.buildable_name.should == 'App.app'
        scheme.profile_action.buildable_product_runnable.buildable_reference.buildable_name.should == 'App.app'
        scheme.test_action.macro_expansions.count.should == 1
      end

      it 'app target not for launching' do
        app = @project.new_target(:application, 'App', :ios)
        scheme = Xcodeproj::XCScheme.new
        scheme.configure_with_targets(app, nil, :launch_target => false)
        scheme.build_action.entries.count.should == 1

        entry = scheme.build_action.entries[0]

        entry.build_for_running?.should == true
        entry.build_for_testing?.should == true
        entry.build_for_profiling?.should == true
        entry.build_for_archiving?.should == true
        entry.build_for_analyzing?.should == true
        entry.buildable_references.first.buildable_name.should == 'App.app'

        scheme.launch_action.buildable_product_runnable.buildable_reference.buildable_name.nil?.should == true
        scheme.profile_action.buildable_product_runnable.buildable_reference.buildable_name.nil?.should == true
        scheme.test_action.macro_expansions.count.should == 0
      end

      it 'app and test target for launching' do
        app = @project.new_target(:application, 'App', :ios)
        test = @project.new_target(:unit_test_bundle, 'Test', :ios)
        scheme = Xcodeproj::XCScheme.new
        scheme.configure_with_targets(app, test, :launch_target => true)
        scheme.build_action.entries.count.should == 2

        app_entry = scheme.build_action.entries[0]
        app_entry.build_for_running?.should == true
        app_entry.build_for_testing?.should == true
        app_entry.build_for_profiling?.should == true
        app_entry.build_for_archiving?.should == true
        app_entry.build_for_analyzing?.should == true
        app_entry.buildable_references.first.buildable_name.should == 'App.app'

        test_entry = scheme.build_action.entries[1]
        test_entry.build_for_running?.should == false
        test_entry.build_for_testing?.should == true
        test_entry.build_for_profiling?.should == false
        test_entry.build_for_archiving?.should == false
        test_entry.build_for_analyzing?.should == false
        test_entry.buildable_references.first.buildable_name.should == 'Test.xctest'

        scheme.launch_action.buildable_product_runnable.buildable_reference.buildable_name.should == 'App.app'
        scheme.profile_action.buildable_product_runnable.buildable_reference.buildable_name.should == 'App.app'
        scheme.test_action.macro_expansions.count.should == 1
      end

      it 'app and test target for not launching' do
        app = @project.new_target(:application, 'App', :ios)
        test = @project.new_target(:unit_test_bundle, 'Test', :ios)
        scheme = Xcodeproj::XCScheme.new
        scheme.configure_with_targets(app, test, :launch_target => false)
        scheme.build_action.entries.count.should == 2

        app_entry = scheme.build_action.entries[0]
        app_entry.build_for_running?.should == true
        app_entry.build_for_testing?.should == true
        app_entry.build_for_profiling?.should == true
        app_entry.build_for_archiving?.should == true
        app_entry.build_for_analyzing?.should == true
        app_entry.buildable_references.first.buildable_name.should == 'App.app'

        test_entry = scheme.build_action.entries[1]
        test_entry.build_for_running?.should == false
        test_entry.build_for_testing?.should == true
        test_entry.build_for_profiling?.should == false
        test_entry.build_for_archiving?.should == false
        test_entry.build_for_analyzing?.should == false
        test_entry.buildable_references.first.buildable_name.should == 'Test.xctest'

        scheme.launch_action.buildable_product_runnable.buildable_reference.buildable_name.nil?.should == true
        scheme.profile_action.buildable_product_runnable.buildable_reference.buildable_name.nil?.should == true
        scheme.test_action.macro_expansions.count.should == 0
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Serialization' do
      extend SpecHelper::TemporaryDirectory

      before do
        app = @project.new_target(:application, 'iOS application', :osx)
        @scheme = Xcodeproj::XCScheme.new
        @scheme.set_launch_target(app)
      end

      it 'indents declares the XML as Xcode' do
        @scheme.to_s.lines.first.chomp.should == '<?xml version="1.0" encoding="UTF-8"?>'
      end

      it 'indents the string representation as Xcode' do
        expected = <<-XML.gsub(/^ {8}/, '')
        <?xml version="1.0" encoding="UTF-8"?>
        <Scheme
           LastUpgradeVersion = "1230"
           version = "1.3">
           <BuildAction
              parallelizeBuildables = "YES"
              buildImplicitDependencies = "YES">
           </BuildAction>
           <TestAction
              buildConfiguration = "Debug"
              selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
              selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
              shouldUseLaunchSchemeArgsEnv = "YES">
              <MacroExpansion>
                 <BuildableReference
                    BuildableIdentifier = "primary"
                    BlueprintIdentifier = "IDENTIFIER"
                    BuildableName = "iOS application.app"
                    BlueprintName = "iOS application"
                    ReferencedContainer = "container:Cocoa Application.xcodeproj">
                 </BuildableReference>
              </MacroExpansion>
              <Testables>
              </Testables>
           </TestAction>
           <LaunchAction
              buildConfiguration = "Debug"
              selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
              selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
              launchStyle = "0"
              useCustomWorkingDirectory = "NO"
              ignoresPersistentStateOnLaunch = "NO"
              debugDocumentVersioning = "YES"
              debugServiceExtension = "internal"
              allowLocationSimulation = "YES">
              <BuildableProductRunnable
                 runnableDebuggingMode = "0">
                 <BuildableReference
                    BuildableIdentifier = "primary"
                    BlueprintIdentifier = "IDENTIFIER"
                    BuildableName = "iOS application.app"
                    BlueprintName = "iOS application"
                    ReferencedContainer = "container:Cocoa Application.xcodeproj">
                 </BuildableReference>
              </BuildableProductRunnable>
           </LaunchAction>
           <ProfileAction
              buildConfiguration = "Release"
              shouldUseLaunchSchemeArgsEnv = "YES"
              savedToolIdentifier = ""
              useCustomWorkingDirectory = "NO"
              debugDocumentVersioning = "YES">
              <BuildableProductRunnable
                 runnableDebuggingMode = "0">
                 <BuildableReference
                    BuildableIdentifier = "primary"
                    BlueprintIdentifier = "IDENTIFIER"
                    BuildableName = "iOS application.app"
                    BlueprintName = "iOS application"
                    ReferencedContainer = "container:Cocoa Application.xcodeproj">
                 </BuildableReference>
              </BuildableProductRunnable>
           </ProfileAction>
           <AnalyzeAction
              buildConfiguration = "Debug">
           </AnalyzeAction>
           <ArchiveAction
              buildConfiguration = "Release"
              revealArchiveInOrganizer = "YES">
           </ArchiveAction>
        </Scheme>
        XML

        actual = @scheme.to_s
        [actual, expected].each { |s| s.gsub!(/BlueprintIdentifier = "\w+"/, 'BlueprintIdentifier = "IDENTIFIER"') }
        actual.should == expected
      end

      it 'saves in place when initialized from file' do
        scheme_dir = 'SharedSchemes/SharedSchemes.xcodeproj/xcshareddata/xcschemes/'
        scheme_name = 'SharedSchemes.xcscheme'
        FileUtils.cp_r fixture_path(scheme_dir + scheme_name), temporary_directory
        temp_file = File.join(temporary_directory, scheme_name)

        scheme = Xcodeproj::XCScheme.new(temp_file)
        FileUtils.rm_r temp_file
        File.exist?(temp_file).should.be.false
        scheme.save!
        File.exist?(temp_file).should.be.true
        File.read(temp_file).should == scheme.to_s
      end

      it 'raises when trying to save in place but not initialized from file' do
        should.raise Xcodeproj::Informative do
          @scheme.save!
        end.message.should.match /This XCScheme object was not initialized using a file path/
      end

      it 'saves in place when file path was specificed by calling save_as ' do
        scheme_name = 'TestScheme'
        scheme_file = File.join temporary_directory, 'xcshareddata', 'xcschemes', scheme_name + '.xcscheme'

        @scheme.save_as(temporary_directory, 'TestScheme', true)
        File.exist?(scheme_file).should.be.true

        FileUtils.rm_r scheme_file
        @scheme.save!

        File.exist?(scheme_file).should.be.true
        File.read(scheme_file).should == @scheme.to_s
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Share a User Scheme' do
      extend SpecHelper::TemporaryDirectory

      before do
        FileUtils.cp_r fixture_path('Sample Project/Cocoa Application.xcodeproj'), temporary_directory
        FileUtils.rm_r File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcshareddata')
        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcshareddata')).should.be.false
      end

      it 'When not exists a previous xcshareddata folder' do
        Xcodeproj::XCScheme.share_scheme(temporary_directory + 'Cocoa Application.xcodeproj', 'Cocoa ApplicationImporter', 'fabio')

        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcshareddata', 'xcschemes', 'Cocoa ApplicationImporter.xcscheme')).should.be.true
        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcuserdata', 'fabio.xcuserdatad', 'xcschemes', 'Cocoa ApplicationImporter.xcscheme')).should.be.false
      end

      it 'When already exists a previous xcshareddata folder' do
        Xcodeproj::XCScheme.share_scheme File.join(temporary_directory, 'Cocoa Application.xcodeproj'), 'Cocoa ApplicationImporter', 'fabio'
        Xcodeproj::XCScheme.share_scheme File.join(temporary_directory, 'Cocoa Application.xcodeproj'), 'iOS application', 'fabio'

        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcshareddata', 'xcschemes', 'Cocoa ApplicationImporter.xcscheme')).should.be.true
        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcshareddata', 'xcschemes', 'iOS application.xcscheme')).should.be.true

        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcuserdata', 'fabio.xcuserdatad', 'xcschemes', 'Cocoa ApplicationImporter.xcscheme')).should.be.false
        File.exist?(File.join(temporary_directory, 'Cocoa Application.xcodeproj', 'xcuserdata', 'fabio.xcuserdatad', 'xcschemes', 'iOS application.xcscheme')).should.be.false
      end
    end

    describe 'Creating a Shared Scheme' do
      before do
        @ios_application = @project.new_target(:application, 'iOS application', :ios)
        @ios_application.stubs(:uuid).returns('E52523F316245AB20012E2BA')
        @ios_application_tests = @project.new_target(:octest_bundle, 'iOS applicationTests', :ios)
        @ios_application_tests.stubs(:uuid).returns('E525241E16245AB20012E2BA')
        @ios_static_library = @project.new_target(:bundle, 'iOS staticLibrary', :osx)
        @ios_static_library.stubs(:uuid).returns('806F6FC217EFAF47001051EE')
        @ios_static_library_tests = @project.new_target(:octest_bundle, 'iOS staticLibraryTests', :ios)
        @ios_static_library_tests.stubs(:uuid).returns('806F6FC217EFAF47001051EE')

        @scheme = Xcodeproj::XCScheme.new
      end

      it 'Supports adding native build targets' do
        @scheme.add_build_target(@ios_application)

        @scheme.doc.root.elements['BuildAction'] \
          .elements['BuildActionEntries'] \
          .elements['BuildActionEntry'] \
          .elements['BuildableReference'] \
          .attributes['BuildableName'].should == @ios_application.product_reference.path
      end

      it 'Supports adding aggregate build targets' do
        aggregate_target = @project.new(PBXAggregateTarget)
        aggregate_target.name = 'Hello'
        @scheme.add_build_target(aggregate_target)

        @scheme.doc.root.elements['BuildAction'] \
          .elements['BuildActionEntries'] \
          .elements['BuildActionEntry'] \
          .elements['BuildableReference'] \
          .attributes['BuildableName'].should == aggregate_target.name
      end

      it 'Does not support adding legacy build targets' do
        legacy_target = @project.new(PBXLegacyTarget)

        should.raise ArgumentError do
          @scheme.add_build_target(legacy_target)
        end.message.should.match /Unsupported build target/
      end

      it 'Constructs ReferencedContainer attributes correctly' do
        project = Xcodeproj::Project.new('/project_dir/Project.xcodeproj')
        target = project.new_target(:application, 'iOS application', :osx)
        buildable_ref = Xcodeproj::XCScheme::BuildableReference.new(nil)

        buildable_ref.send(:construct_referenced_container_uri, target).should == 'container:Project.xcodeproj'

        project.root_object.project_dir_path = '/a_dir'
        buildable_ref.send(:construct_referenced_container_uri, target).should == 'container:../project_dir/Project.xcodeproj'
      end

      it 'Constructs a reference to a different project correctly' do
        project = Xcodeproj::Project.new('/project_dir/Project.xcodeproj')
        another_project = Xcodeproj::Project.new('/another_project_dir/AnotherProject.xcodeproj')
        target = another_project.new_target(:application, 'iOS application', :osx)
        buildable_ref = Xcodeproj::XCScheme::BuildableReference.new(nil)

        buildable_ref.send(:construct_referenced_container_uri, target, project).should == 'container:../another_project_dir/AnotherProject.xcodeproj'
      end

      describe 'For iOS Application' do
        before do
          @scheme.add_build_target(@ios_application)
          @scheme.add_test_target(@ios_application_tests)
          @scheme.set_launch_target(@ios_application)
          @xml = REXML::Document.new File.new fixture_path('Sample Project/Cocoa Application.xcodeproj/xcshareddata/xcschemes/iOS application.xcscheme')
        end

        it 'XML Decl' do
          @xml.xml_decl.should.be.equal @scheme.doc.xml_decl
        end

        it 'Scheme' do
          compare_elements @xml.root, @scheme.doc.root
        end

        it 'Scheme > BuildAction' do
          compare_elements @xml.root.elements['BuildAction'], @scheme.doc.root.elements['BuildAction']
        end

        it 'Scheme > BuildAction > BuildActionEntries' do
          compare_elements \
            @xml.root.elements['BuildAction'] \
              .elements['BuildActionEntries'], \
            @scheme.doc.root.elements['BuildAction'] \
              .elements['BuildActionEntries']
        end

        it 'Scheme > BuildAction > BuildActionEntries > BuildActionEntry' do
          compare_elements \
            @xml.root.elements['BuildAction'] \
              .elements['BuildActionEntries'] \
              .elements['BuildActionEntry'], \
            @scheme.doc.root.elements['BuildAction'] \
              .elements['BuildActionEntries'] \
              .elements['BuildActionEntry']
        end

        it 'Scheme > BuildAction > BuildActionEntries > BuildActionEntry > BuildableReference' do
          compare_elements \
            @xml.root.elements['BuildAction'] \
              .elements['BuildActionEntries'] \
              .elements['BuildActionEntry'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['BuildAction'] \
              .elements['BuildActionEntries'] \
              .elements['BuildActionEntry'] \
              .elements['BuildableReference']
        end

        it 'Scheme > TestAction' do
          compare_elements @xml.root.elements['TestAction'], @scheme.doc.root.elements['TestAction']
        end

        it 'Scheme > TestAction > Testables' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables']
        end

        it 'Scheme > TestAction > Testables > TestableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference']
        end

        it 'Scheme > TestAction > Testables > TestableReference > BuildableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference']
        end

        it 'Scheme > TestAction > MacroExpansion' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['MacroExpansion'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['MacroExpansion']
        end

        it 'Scheme > TestAction > MacroExpansion > BuildableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['MacroExpansion'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['MacroExpansion'] \
              .elements['BuildableReference']
        end

        it 'Scheme > LaunchAction' do
          compare_elements @xml.root.elements['LaunchAction'], @scheme.doc.root.elements['LaunchAction']
        end

        it 'Scheme > LaunchAction > BuildableProductRunnable' do
          compare_elements \
            @xml.root.elements['LaunchAction'] \
              .elements['BuildableProductRunnable'], \
            @scheme.doc.root.elements['LaunchAction'] \
              .elements['BuildableProductRunnable']
        end

        it 'Scheme > LaunchAction > BuildableProductRunnable > BuildableReference' do
          compare_elements \
            @xml.root.elements['LaunchAction'] \
              .elements['BuildableProductRunnable'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['LaunchAction'] \
              .elements['BuildableProductRunnable'] \
              .elements['BuildableReference']
        end

        it 'Scheme > LaunchAction > AdditionalOptions' do
          compare_elements \
            @xml.root.elements['LaunchAction'] \
              .elements['AdditionalOptions'], \
            @scheme.doc.root.elements['LaunchAction'] \
              .elements['AdditionalOptions']
        end

        it 'Scheme > ProfileAction' do
          compare_elements @xml.root.elements['ProfileAction'], @scheme.doc.root.elements['ProfileAction']
        end

        it 'Scheme > ProfileAction > BuildableProductRunnable' do
          compare_elements @xml.root.elements['ProfileAction'] \
            .elements['BuildableProductRunnable'], \
                           @scheme.doc.root.elements['ProfileAction'] \
                             .elements['BuildableProductRunnable']
        end

        it 'Scheme > ProfileAction > BuildableProductRunnable > BuildableReference' do
          compare_elements @xml.root.elements['ProfileAction'] \
            .elements['BuildableProductRunnable'] \
            .elements['BuildableReference'], \
                           @scheme.doc.root.elements['ProfileAction'] \
                             .elements['BuildableProductRunnable'] \
                             .elements['BuildableReference']
        end

        it 'Scheme > AnalyzeAction' do
          compare_elements @xml.root.elements['AnalyzeAction'], @scheme.doc.root.elements['AnalyzeAction']
        end

        it 'Scheme > ArchiveAction' do
          compare_elements @xml.root.elements['ArchiveAction'], @scheme.doc.root.elements['ArchiveAction']
        end
      end

      describe 'For iOS Application Tests' do
        before do
          @scheme.add_test_target(@ios_application_tests)
          @xml = REXML::Document.new File.new fixture_path('Sample Project/Cocoa Application.xcodeproj/xcshareddata/xcschemes/iOS applicationTests.xcscheme')
        end

        it 'XML Decl' do
          @xml.xml_decl.should.be.equal @scheme.doc.xml_decl
        end

        it 'Scheme' do
          compare_elements @xml.root, @scheme.doc.root
        end

        it 'Scheme > BuildAction' do
          compare_elements @xml.root.elements['BuildAction'], @scheme.doc.root.elements['BuildAction']
        end

        it 'Scheme > TestAction' do
          compare_elements @xml.root.elements['TestAction'], @scheme.doc.root.elements['TestAction']
        end

        it 'Scheme > TestAction > Testables' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables']
        end

        it 'Scheme > TestAction > Testables > TestableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference']
        end

        it 'Scheme > TestAction > Testables > TestableReference > BuildableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference']
        end

        it 'Scheme > LaunchAction' do
          compare_elements @xml.root.elements['LaunchAction'], @scheme.doc.root.elements['LaunchAction']
        end

        it 'Scheme > LaunchAction > AdditionalOptions' do
          compare_elements \
            @xml.root.elements['LaunchAction'] \
              .elements['AdditionalOptions'], \
            @scheme.doc.root.elements['LaunchAction'] \
              .elements['AdditionalOptions']
        end

        it 'Scheme > ProfileAction' do
          compare_elements @xml.root.elements['ProfileAction'], @scheme.doc.root.elements['ProfileAction']
        end

        it 'Scheme > AnalyzeAction' do
          compare_elements @xml.root.elements['AnalyzeAction'], @scheme.doc.root.elements['AnalyzeAction']
        end

        it 'Scheme > ArchiveAction' do
          compare_elements @xml.root.elements['ArchiveAction'], @scheme.doc.root.elements['ArchiveAction']
        end
      end

      #-------------------------------------------------------------------------#

      describe 'For iOS Application Tests (Set Build Target For Running)' do
        extend SpecHelper::TemporaryDirectory

        before do
          @scheme.add_build_target(@ios_application_tests)
          @scheme.add_test_target(@ios_application_tests)
          @xml = REXML::Document.new File.new fixture_path('Sample Project/Cocoa Application.xcodeproj/xcshareddata/xcschemes/iOS applicationTests Set Build Target For Running.xcscheme')
        end

        it 'XML Decl' do
          @xml.xml_decl.should.be.equal @scheme.doc.xml_decl
        end

        it 'Scheme' do
          compare_elements @xml.root, @scheme.doc.root
        end

        it 'Scheme > BuildAction' do
          compare_elements @xml.root.elements['BuildAction'], @scheme.doc.root.elements['BuildAction']
        end

        it 'Scheme > TestAction' do
          compare_elements @xml.root.elements['TestAction'], @scheme.doc.root.elements['TestAction']
        end

        it 'Scheme > TestAction > Testables' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables']
        end

        it 'Scheme > TestAction > Testables > TestableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference']
        end

        it 'Scheme > TestAction > Testables > TestableReference > BuildableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference']
        end

        it 'Scheme > LaunchAction' do
          compare_elements @xml.root.elements['LaunchAction'], @scheme.doc.root.elements['LaunchAction']
        end

        it 'Scheme > LaunchAction > AdditionalOptions' do
          compare_elements \
            @xml.root.elements['LaunchAction'] \
              .elements['AdditionalOptions'], \
            @scheme.doc.root.elements['LaunchAction'] \
              .elements['AdditionalOptions']
        end

        it 'Scheme > ProfileAction' do
          compare_elements @xml.root.elements['ProfileAction'], @scheme.doc.root.elements['ProfileAction']
        end

        it 'Scheme > AnalyzeAction' do
          compare_elements @xml.root.elements['AnalyzeAction'], @scheme.doc.root.elements['AnalyzeAction']
        end

        it 'Scheme > ArchiveAction' do
          compare_elements @xml.root.elements['ArchiveAction'], @scheme.doc.root.elements['ArchiveAction']
        end

        it 'Save as Shared Scheme' do
          result = @scheme.save_as(temporary_directory, 'iOS applicationTests', true)
          (result > 0).should.be.true
          File.exist?(File.join temporary_directory, 'xcshareddata', 'xcschemes', 'iOS applicationTests.xcscheme').should.be.true
        end

        it 'Save as User Scheme' do
          result = @scheme.save_as(temporary_directory, 'iOS applicationTests', false)
          (result > 0).should.be.true
          File.exist?(File.join temporary_directory, 'xcuserdata', "#{ENV['USER']}.xcuserdatad", 'xcschemes', 'iOS applicationTests.xcscheme').should.be.true
        end
      end

      #-------------------------------------------------------------------------#

      describe 'For iOS Application And Static Library' do
        extend SpecHelper::TemporaryDirectory

        before do
          @scheme.add_build_target(@ios_application)
          @scheme.add_build_target(@ios_static_library)
          @scheme.add_test_target(@ios_application_tests)
          @scheme.add_test_target(@ios_static_library_tests)
          @scheme.set_launch_target(@ios_application)
          @xml = REXML::Document.new File.new fixture_path('Sample Project/Cocoa Application.xcodeproj/xcshareddata/xcschemes/iOS application and static library.xcscheme')
        end

        it 'XML Decl' do
          @xml.xml_decl.should.be.equal @scheme.doc.xml_decl
        end

        it 'Scheme' do
          compare_elements @xml.root, @scheme.doc.root
        end

        it 'Scheme > BuildAction' do
          compare_elements @xml.root.elements['BuildAction'], @scheme.doc.root.elements['BuildAction']
        end

        it 'Scheme > TestAction' do
          compare_elements @xml.root.elements['TestAction'], @scheme.doc.root.elements['TestAction']
        end

        it 'Scheme > TestAction > Testables' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables']
        end

        it 'Scheme > TestAction > Testables > TestableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference']
        end

        it 'Scheme > TestAction > Testables > TestableReference > BuildableReference' do
          compare_elements \
            @xml.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference'], \
            @scheme.doc.root.elements['TestAction'] \
              .elements['Testables'] \
              .elements['TestableReference'] \
              .elements['BuildableReference']
        end

        it 'Scheme > LaunchAction' do
          compare_elements @xml.root.elements['LaunchAction'], @scheme.doc.root.elements['LaunchAction']
        end

        it 'Scheme > LaunchAction > AdditionalOptions' do
          compare_elements \
            @xml.root.elements['LaunchAction'] \
              .elements['AdditionalOptions'], \
            @scheme.doc.root.elements['LaunchAction'] \
              .elements['AdditionalOptions']
        end

        it 'Scheme > ProfileAction' do
          compare_elements @xml.root.elements['ProfileAction'], @scheme.doc.root.elements['ProfileAction']
        end

        it 'Scheme > AnalyzeAction' do
          compare_elements @xml.root.elements['AnalyzeAction'], @scheme.doc.root.elements['AnalyzeAction']
        end

        it 'Scheme > ArchiveAction' do
          compare_elements @xml.root.elements['ArchiveAction'], @scheme.doc.root.elements['ArchiveAction']
        end

        it 'Save as Shared Scheme' do
          result = @scheme.save_as(temporary_directory, 'iOS applicationTests', true)
          (result > 0).should.be.true
          File.exist?(File.join temporary_directory, 'xcshareddata', 'xcschemes', 'iOS applicationTests.xcscheme').should.be.true
        end

        it 'Save as User Scheme' do
          result = @scheme.save_as(temporary_directory, 'iOS applicationTests', false)
          (result > 0).should.be.true
          File.exist?(File.join temporary_directory, 'xcuserdata', "#{ENV['USER']}.xcuserdatad", 'xcschemes', 'iOS applicationTests.xcscheme').should.be.true
        end
      end
    end

    #-------------------------------------------------------------------------#
  end
end
