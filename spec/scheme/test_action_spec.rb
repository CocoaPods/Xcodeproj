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

      xit '#testables' do
        # @todo
      end

      xit '#add_testables' do
        # @todo
      end

      xit '#macro_expansions' do
        # @todo
      end

      xit '#add_macro_expansion' do
        # @todo
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
