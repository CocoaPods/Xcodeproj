require File.expand_path('../spec_helper', __FILE__)

def compare_elements(a, b)
  a.attributes.should.be.equal b.attributes
  a.elements.count.should.be.equal b.elements.count
end

module ProjectSpecs
  describe Xcodeproj::XCScheme do
    before do
      @project.stubs(:path).returns(Pathname.new('path/Cocoa Application.xcodeproj'))
    end

    #-------------------------------------------------------------------------#

    describe 'Serialization' do
      before do
        app = @project.new_target(:application, 'iOS application', :osx)
        @scheme = Xcodeproj::XCScheme.new
        @scheme.set_launch_target(app)
      end

      it 'indents declares the XML as Xcode' do
        @scheme.to_s.lines.first.chomp.should == '<?xml version="1.0" encoding="UTF-8"?>'
      end

      it 'indents the string representation as Xcode' do
        require 'active_support/core_ext/string/strip.rb'
        @scheme.to_s[0..190].should == <<-DOC.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <Scheme
           LastUpgradeVersion = "0510"
           version = "1.3">
           <BuildAction
              parallelizeBuildables = "YES"
              buildImplicitDependencies = "YES">
        DOC
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
        @ios_application = @project.new_target(:application, 'iOS application', :osx)
        @ios_application.stubs(:uuid).returns('E52523F316245AB20012E2BA')
        @ios_application_tests = @project.new_target(:bundle, 'iOS applicationTests', :osx)
        @ios_application_tests.stubs(:uuid).returns('E525241E16245AB20012E2BA')
        @ios_static_library = @project.new_target(:bundle, 'iOS staticLibrary', :osx)
        @ios_static_library.stubs(:uuid).returns('806F6FC217EFAF47001051EE')
        @ios_static_library_tests = @project.new_target(:bundle, 'iOS staticLibraryTests', :osx)
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

        @scheme.send(:construct_referenced_container_uri, target).should == 'container:Project.xcodeproj'

        project.root_object.project_dir_path = '/a_dir'
        @scheme.send(:construct_referenced_container_uri, target).should == 'container:../project_dir/Project.xcodeproj'
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
