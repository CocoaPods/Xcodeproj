require File.expand_path('../spec_helper', __FILE__)

def compare_elements a, b
  a.attributes.should.be.equal b.attributes
  a.elements.count.should.be.equal b.elements.count
end

describe Xcodeproj::XCScheme do
  describe 'Creating a Shared Scheme' do

    before do
      @project = Xcodeproj::Project.new(fixture_path('Sample Project/Cocoa Application.xcodeproj'))
      @project.targets.each do |target|
        if target.name == 'iOS application' then
          @ios_application = target
        end
        if target.name == 'iOS applicationTests' then
          @ios_application_tests = target
        end
      end
    end

    describe 'For iOS Application' do
      
      before do
        @scheme = Xcodeproj::XCScheme.new 'Cocoa Application', @ios_application, @ios_application_tests
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
        @scheme = Xcodeproj::XCScheme.new 'Cocoa Application', @ios_application_tests, @ios_application_tests
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

    describe 'For iOS Application Tests (Set Build Target For Running)' do
      
      before do
        @scheme = Xcodeproj::XCScheme.new 'Cocoa Application', @ios_application_tests, @ios_application_tests
        
        @scheme.build_target_for_running.should.be.false
        
        @scheme.build_target_for_running = true
        
        @scheme.build_target_for_running.should.be.true
        
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
        result = @scheme.save_as(SpecHelper::TemporaryDirectory::temporary_directory, true)
        result.should.be.true
        File.exists? File.join SpecHelper::TemporaryDirectory::temporary_directory, 'xcshareddata', 'xcschemes', 'iOS applicationTests.xcscheme'
      end

      it 'Save as User Scheme' do
        result = @scheme.save_as(SpecHelper::TemporaryDirectory::temporary_directory, false)
        result.should.be.true
        File.exists? File.join SpecHelper::TemporaryDirectory::temporary_directory, 'xcuserdata', "#{ENV['USER']}.xcuserdatad", 'xcschemes', 'iOS applicationTests.xcscheme'
      end

    end
    
  end
end
