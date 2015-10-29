require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::BuildAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::BuildAction.new(nil)
      action.xml_element.name.should == 'BuildAction'
      action.xml_element.attributes.count.should == 2
      action.xml_element.attributes['parallelizeBuildables'].should == 'YES'
      action.xml_element.attributes['buildImplicitDependencies'].should == 'YES'
      action.xml_element.elements.count.should == 0
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::BuildAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(node)
      end

      extend SpecHelper::XCScheme
      attributes = {
        :parallelize_buildables => 'parallelizeBuildables',
        :build_implicit_dependencies => 'buildImplicitDependencies',
      }
      specs_for_bool_attr(attributes)

      it '#add_entry' do
        @sut.xml_element.elements['BuildActionEntries'].should.nil?
        entry = XCScheme::BuildAction::Entry.new
        @sut.add_entry(entry)
        @sut.xml_element.elements['BuildActionEntries'].should.not.nil?
        @sut.xml_element.elements['BuildActionEntries'].count.should == 1
        @sut.xml_element.elements['BuildActionEntries'].elements['BuildActionEntry'].should == entry.xml_element
      end

      it '#entries' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        entry1 = XCScheme::BuildAction::Entry.new
        entry1.add_buildable_reference(XCScheme::BuildableReference.new(target1))
        @sut.add_entry(entry1)

        target2 = project.new_target(:static_library, 'FooLib', :ios)
        entry2 = XCScheme::BuildAction::Entry.new
        entry2.add_buildable_reference(XCScheme::BuildableReference.new(target2))
        @sut.add_entry(entry2)

        @sut.entries.count.should == 2
        @sut.entries.all? { |e| e.class.should == XCScheme::BuildAction::Entry }
        @sut.entries[0].xml_element.should == entry1.xml_element
        @sut.entries[1].xml_element.should == entry2.xml_element
      end
    end

    describe XCScheme::BuildAction::Entry do
      it 'Creates a default XML node when created from scratch' do
        entry = Xcodeproj::XCScheme::BuildAction::Entry.new(nil)

        entry.xml_element.name.should == 'BuildActionEntry'
        entry.xml_element.attributes.count.should == 5
        entry.xml_element.attributes['buildForAnalyzing'].should == 'YES'
        entry.xml_element.attributes['buildForTesting'].should == 'NO'
        entry.xml_element.attributes['buildForRunning'].should == 'NO'
        entry.xml_element.attributes['buildForProfiling'].should == 'NO'
        entry.xml_element.attributes['buildForArchiving'].should == 'NO'
        entry.xml_element.elements.count.should == 0
      end

      it 'raises if created with an invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::BuildAction::Entry.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      describe 'Created from a target' do
        before do
          @project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        end
        it 'Uses the proper XML node' do
          target = @project.new_target(:application, 'FooApp', :ios)
          entry = Xcodeproj::XCScheme::BuildAction::Entry.new(target)
          entry.xml_element.name.should == 'BuildActionEntry'
        end

        it 'Use proper defaults for app target' do
          target = @project.new_target(:application, 'FooApp', :ios)
          entry = Xcodeproj::XCScheme::BuildAction::Entry.new(target)
          entry.build_for_testing?.should == false
          entry.build_for_running?.should == true
          entry.build_for_profiling?.should == true
          entry.build_for_archiving?.should == true
          entry.build_for_analyzing?.should == true
        end

        it 'Use proper defaults for lib target' do
          target = @project.new_target(:static_library, 'FooLib', :ios)
          entry = Xcodeproj::XCScheme::BuildAction::Entry.new(target)
          entry.build_for_testing?.should == false
          entry.build_for_running?.should == false
          entry.build_for_profiling?.should == false
          entry.build_for_archiving?.should == false
          entry.build_for_analyzing?.should == true
        end

        it 'Use proper defaults for test target' do
          target = @project.new_target(:unit_test_bundle, 'FooAppTests', :ios)
          entry = Xcodeproj::XCScheme::BuildAction::Entry.new(target)
          entry.build_for_testing?.should == true
          entry.build_for_running?.should == false
          entry.build_for_profiling?.should == false
          entry.build_for_archiving?.should == false
          entry.build_for_analyzing?.should == true
        end
      end

      describe 'Map attributes to XML' do
        before do
          @sut = Xcodeproj::XCScheme::BuildAction::Entry.new(nil)
        end

        extend SpecHelper::XCScheme
        attributes = {
          :build_for_testing => 'buildForTesting',
          :build_for_running => 'buildForRunning',
          :build_for_profiling => 'buildForProfiling',
          :build_for_archiving => 'buildForArchiving',
          :build_for_analyzing => 'buildForAnalyzing',
        }
        specs_for_bool_attr(attributes)
      end

      it '#add_buildable_reference' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        entry = XCScheme::BuildAction::Entry.new

        target = project.new_target(:application, 'FooApp', :ios)
        ref = XCScheme::BuildableReference.new(target)
        entry.add_buildable_reference(ref)

        entry.xml_element.elements['BuildableReference'].should == ref.xml_element
      end

      it '#buildable_references' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        entry = XCScheme::BuildAction::Entry.new

        target1 = project.new_target(:application, 'FooApp', :ios)
        ref1 = XCScheme::BuildableReference.new(target1)
        entry.add_buildable_reference(ref1)

        target2 = project.new_target(:static_library, 'FooLib', :ios)
        ref2 = XCScheme::BuildableReference.new(target2)
        entry.add_buildable_reference(ref2)

        entry.buildable_references.count.should == 2
        entry.buildable_references.all? { |e| e.class.should == XCScheme::BuildableReference }
        entry.buildable_references[0].xml_element.should == ref1.xml_element
        entry.buildable_references[1].xml_element.should == ref2.xml_element
      end
    end
  end
end
