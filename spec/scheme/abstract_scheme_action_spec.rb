require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::AbstractSchemeAction do
    before do
      @sut = Xcodeproj::XCScheme::AbstractSchemeAction.new
      @sut.instance_eval { @xml_element = REXML::Element.new('Foo') }
    end

    describe '#build_configuration' do
      it 'get the value if it exists' do
        @sut.xml_element.attributes['buildConfiguration'] = 'Bar'
        @sut.build_configuration.should == 'Bar'
      end

      it 'return nil if it does not exist' do
        @sut.build_configuration.should.nil?
      end

      it 'sets the value' do
        @sut.build_configuration = 'Baz'
        @sut.xml_element.attributes['buildConfiguration'].should == 'Baz'
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
end
