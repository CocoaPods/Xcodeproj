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
        :run_post_actions_on_failure => 'runPostActionsOnFailure',
      }
      specs_for_bool_attr(attributes)

      it '#add_pre_action' do
        @sut.xml_element.elements['PreActions'].should.nil?
        pre_action = XCScheme::ExecutionAction.new(nil, :shell_script)
        @sut.add_pre_action(pre_action)
        @sut.xml_element.elements['PreActions'].should.not.nil?
        @sut.xml_element.elements['PreActions'].count.should == 1
        @sut.xml_element.elements['PreActions'].elements['ExecutionAction'].should == pre_action.xml_element
      end

      it '#add_post_action' do
        @sut.xml_element.elements['PostActions'].should.nil?
        post_action = XCScheme::ExecutionAction.new(nil, :shell_script)
        @sut.add_post_action(post_action)
        @sut.xml_element.elements['PostActions'].should.not.nil?
        @sut.xml_element.elements['PostActions'].count.should == 1
        @sut.xml_element.elements['PostActions'].elements['ExecutionAction'].should == post_action.xml_element
      end

      it '#add_entry' do
        @sut.xml_element.elements['BuildActionEntries'].should.nil?
        entry = XCScheme::BuildAction::Entry.new
        @sut.add_entry(entry)
        @sut.xml_element.elements['BuildActionEntries'].should.not.nil?
        @sut.xml_element.elements['BuildActionEntries'].count.should == 1
        @sut.xml_element.elements['BuildActionEntries'].elements['BuildActionEntry'].should == entry.xml_element
      end

      describe '#entries' do
        it 'when there are no entries' do
          @sut.xml_element.elements['BuildActionEntries'].should.nil?
          @sut.entries.should.nil?
        end

        it '#entries=' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

          target1 = project.new_target(:application, 'FooApp', :ios)
          entry1 = XCScheme::BuildAction::Entry.new
          entry1.add_buildable_reference(XCScheme::BuildableReference.new(target1))

          target2 = project.new_target(:static_library, 'FooLib', :ios)
          entry2 = XCScheme::BuildAction::Entry.new
          entry2.add_buildable_reference(XCScheme::BuildableReference.new(target2))

          @sut.entries = [entry1, entry2]

          @sut.entries.count.should == 2
          @sut.entries.all? { |e| e.class.should == XCScheme::BuildAction::Entry }
          @sut.entries[0].xml_element.should == entry1.xml_element
          @sut.entries[1].xml_element.should == entry2.xml_element
        end

        it 'when there are entries' do
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

      describe '#pre_actions' do
        it 'when there are no pre_actions' do
          @sut.xml_element.elements['PreActions'].should.nil?
          @sut.pre_actions.should.nil?
        end

        it '#pre_actions=' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

          target1 = project.new_target(:application, 'FooApp', :ios)
          pre_action1 = XCScheme::ExecutionAction.new(nil, :shell_script)
          action_content1 = XCScheme::ShellScriptActionContent.new
          buildable_reference1 = XCScheme::BuildableReference.new(target1)
          action_content1.buildable_reference = buildable_reference1
          pre_action1.action_content = action_content1

          pre_action2 = XCScheme::ExecutionAction.new(nil, :send_email)
          action_content2 = XCScheme::SendEmailActionContent.new
          pre_action2.action_content = action_content2

          @sut.pre_actions = [pre_action1, pre_action2]

          @sut.pre_actions.count.should == 2
          @sut.pre_actions.all? { |e| e.class.should == XCScheme::ExecutionAction }
          @sut.pre_actions[0].xml_element.should == pre_action1.xml_element
          @sut.pre_actions[1].xml_element.should == pre_action2.xml_element
        end

        it 'when there are pre_actions' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

          target1 = project.new_target(:application, 'FooApp', :ios)
          pre_action1 = XCScheme::ExecutionAction.new(nil, :shell_script)
          action_content1 = XCScheme::ShellScriptActionContent.new
          buildable_reference1 = XCScheme::BuildableReference.new(target1)
          action_content1.buildable_reference = buildable_reference1
          pre_action1.action_content = action_content1
          @sut.add_pre_action(pre_action1)

          pre_action2 = XCScheme::ExecutionAction.new(nil, :send_email)
          action_content2 = XCScheme::SendEmailActionContent.new
          pre_action2.action_content = action_content2
          @sut.add_pre_action(pre_action2)

          @sut.pre_actions.count.should == 2
          @sut.pre_actions.all? { |e| e.class.should == XCScheme::ExecutionAction }
          @sut.pre_actions[0].xml_element.should == pre_action1.xml_element
          @sut.pre_actions[1].xml_element.should == pre_action2.xml_element
        end
      end

      describe '#post_actions' do
        it 'when there are no post_actions' do
          @sut.xml_element.elements['PostActions'].should.nil?
          @sut.post_actions.should.nil?
        end

        it '#post_actions=' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

          target1 = project.new_target(:application, 'FooApp', :ios)
          post_action1 = XCScheme::ExecutionAction.new(nil, :shell_script)
          action_content1 = XCScheme::ShellScriptActionContent.new
          buildable_reference1 = XCScheme::BuildableReference.new(target1)
          action_content1.buildable_reference = buildable_reference1
          post_action1.action_content = action_content1

          post_action2 = XCScheme::ExecutionAction.new(nil, :send_email)
          action_content2 = XCScheme::SendEmailActionContent.new
          post_action2.action_content = action_content2

          @sut.post_actions = [post_action1, post_action2]

          @sut.post_actions.count.should == 2
          @sut.post_actions.all? { |e| e.class.should == XCScheme::ExecutionAction }
          @sut.post_actions[0].xml_element.should == post_action1.xml_element
          @sut.post_actions[1].xml_element.should == post_action2.xml_element
        end

        it 'when there are post_actions' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

          target1 = project.new_target(:application, 'FooApp', :ios)
          post_action1 = XCScheme::ExecutionAction.new(nil, :shell_script)
          action_content1 = XCScheme::ShellScriptActionContent.new
          buildable_reference1 = XCScheme::BuildableReference.new(target1)
          action_content1.buildable_reference = buildable_reference1
          post_action1.action_content = action_content1
          @sut.add_post_action(post_action1)

          post_action2 = XCScheme::ExecutionAction.new(nil, :send_email)
          action_content2 = XCScheme::SendEmailActionContent.new
          post_action2.action_content = action_content2
          @sut.add_post_action(post_action2)

          @sut.post_actions.count.should == 2
          @sut.post_actions.all? { |e| e.class.should == XCScheme::ExecutionAction }
          @sut.post_actions[0].xml_element.should == post_action1.xml_element
          @sut.post_actions[1].xml_element.should == post_action2.xml_element
        end
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

        it 'Use proper defaults for UI test target' do
          target = @project.new_target(:ui_test_bundle, 'FooUITests', :ios)
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

      it '#remove_buildable_reference' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        entry = XCScheme::BuildAction::Entry.new

        target = project.new_target(:application, 'FooApp', :ios)
        ref = XCScheme::BuildableReference.new(target)
        entry.add_buildable_reference(ref)
        entry.xml_element.elements['BuildableReference'].should == ref.xml_element
        entry.remove_buildable_reference(ref)
        entry.xml_element.elements['BuildableReference'].should.nil?
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
