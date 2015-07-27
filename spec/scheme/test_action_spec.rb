require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::TestAction do
    it 'Creates a default XML node when created from scratch' do
      test_action = Xcodeproj::XCScheme::TestAction.new(nil)
      test_action.xml_element.name.should == 'TestAction'
      test_action.xml_element.attributes.count.should == 4
      test_action.xml_element.attributes['selectedDebuggerIdentifier'].should == 'Xcode.DebuggerFoundation.Debugger.LLDB'
      test_action.xml_element.attributes['selectedLauncherIdentifier'].should == 'Xcode.DebuggerFoundation.Launcher.LLDB'
      test_action.xml_element.attributes['shouldUseLaunchSchemeArgsEnv'].should == 'YES'
      test_action.xml_element.attributes['buildConfiguration'].should == 'Debug'
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::TestAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('TestAction')
        @sut = Xcodeproj::XCScheme::TestAction.new(node)
      end

      extend SpecHelper::XCScheme
      specs_for_bool_attr(:should_use_launch_scheme_args_env => 'shouldUseLaunchSchemeArgsEnv')

      it '#testables' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @sut.xml_element.add_element('Testables')
        
        target1 = project.new_target(:application, 'FooApp', :ios)
        test_ref1 = XCScheme::TestAction::TestableReference.new(target1)
        @sut.xml_element.elements['Testables'].add_element(test_ref1.xml_element)

        target2 = project.new_target(:application, 'FooApp', :ios)
        test_ref2 = XCScheme::TestAction::TestableReference.new(target2)
        @sut.xml_element.elements['Testables'].add_element(test_ref2.xml_element)

        @sut.testables.count.should == 2
        @sut.testables.all? { |t| t.class.should == XCScheme::TestAction::TestableReference }
        @sut.testables[0].xml_element.should == test_ref1.xml_element
        @sut.testables[1].xml_element.should == test_ref2.xml_element
      end

      it '#add_testables' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        test_ref1 = XCScheme::TestAction::TestableReference.new(target1)
        @sut.add_testable(test_ref1)

        target2 = project.new_target(:application, 'FooApp', :ios)
        test_ref2 = XCScheme::TestAction::TestableReference.new(target2)
        @sut.add_testable(test_ref2)

        @sut.xml_element.elements['Testables'].count.should == 2
        @sut.xml_element.elements['Testables/TestableReference[1]'].should == test_ref1.xml_element
        @sut.xml_element.elements['Testables/TestableReference[2]'].should == test_ref2.xml_element
      end

      it '#macro_expansions' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @sut.xml_element.add_element('Testables')
        
        target1 = project.new_target(:application, 'FooApp', :ios)
        macro1 = XCScheme::MacroExpansion.new(target1)
        @sut.xml_element.add_element(macro1.xml_element)

        target2 = project.new_target(:application, 'FooApp', :ios)
        macro2 = XCScheme::MacroExpansion.new(target2)
        @sut.xml_element.add_element(macro2.xml_element)

        @sut.macro_expansions.count.should == 2
        @sut.macro_expansions.all? { |m| m.class.should == XCScheme::MacroExpansion }
        @sut.macro_expansions[0].xml_element.should == macro1.xml_element
        @sut.macro_expansions[1].xml_element.should == macro2.xml_element
      end

      it '#add_macro_expansion' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        macro1 = XCScheme::MacroExpansion.new(target1)
        @sut.add_macro_expansion(macro1)

        target2 = project.new_target(:application, 'FooApp', :ios)
        macro2 = XCScheme::MacroExpansion.new(target2)
        @sut.add_macro_expansion(macro2)

        @sut.xml_element.get_elements('MacroExpansion').count.should == 2
        @sut.xml_element.elements['MacroExpansion[1]'].should == macro1.xml_element
        @sut.xml_element.elements['MacroExpansion[2]'].should == macro2.xml_element
      end
    end

    describe XCScheme::TestAction::TestableReference do
      it 'Creates a default XML node when created from scratch' do
        test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(nil)

        test_ref.xml_element.name.should == 'TestableReference'
        test_ref.xml_element.attributes.count.should == 1
        test_ref.xml_element.attributes['skipped'].should == 'NO'
      end

      it 'raises if created with an invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::TestAction::TestableReference.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it 'Uses the proper XML node when created from a target' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        target = project.new_target(:application, 'FooApp', :ios)
        test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(target)
        test_ref.xml_element.name.should == 'TestableReference'
      end

      describe 'Map attributes to XML' do
        extend SpecHelper::XCScheme

        before do
          @sut = Xcodeproj::XCScheme::TestAction::TestableReference.new(nil)
        end

        attributes = {
          :skipped => 'skipped',
        }
        specs_for_bool_attr(attributes)
      end

      it '#add_buildable_reference' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        test_ref = XCScheme::TestAction::TestableReference.new

        target = project.new_target(:application, 'FooApp', :ios)
        ref = XCScheme::BuildableReference.new(target)
        test_ref.add_buildable_reference(ref)

        test_ref.xml_element.elements['BuildableReference'].should == ref.xml_element
      end

      it '#buildable_references' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        test_ref = XCScheme::TestAction::TestableReference.new

        target1 = project.new_target(:application, 'FooApp', :ios)
        ref1 = XCScheme::BuildableReference.new(target1)
        test_ref.add_buildable_reference(ref1)

        target2 = project.new_target(:static_library, 'FooLib', :ios)
        ref2 = XCScheme::BuildableReference.new(target2)
        test_ref.add_buildable_reference(ref2)

        test_ref.buildable_references.count.should == 2
        test_ref.buildable_references.all? { |e| e.class.should == XCScheme::BuildableReference }
        test_ref.buildable_references[0].xml_element.should == ref1.xml_element
        test_ref.buildable_references[1].xml_element.should == ref2.xml_element
      end
    end
  end
end
