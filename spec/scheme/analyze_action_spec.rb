require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::AnalyzeAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::AnalyzeAction.new(nil)
      action.xml_element.name.should == 'AnalyzeAction'
      action.xml_element.attributes.count.should == 1
      action.xml_element.attributes['buildConfiguration'].should == 'Debug'
    end

    it 'ensure pre and post actions are disabled' do
      action = Xcodeproj::XCScheme::AnalyzeAction.new(nil)

      pre_action1 = Xcodeproj::XCScheme::ExecutionAction.new(Constants::EXECUTION_ACTION_TYPE[:send_email])
      pre_action2 = Xcodeproj::XCScheme::ExecutionAction.new(Constants::EXECUTION_ACTION_TYPE[:send_email])

      action.pre_actions = Array(pre_action1)
      action.add_pre_action(pre_action2)
      action.pre_actions.should.nil?
      action.xml_element.elements['PreActions'].should.nil?

      post_action1 = Xcodeproj::XCScheme::ExecutionAction.new(Constants::EXECUTION_ACTION_TYPE[:send_email])
      post_action2 = Xcodeproj::XCScheme::ExecutionAction.new(Constants::EXECUTION_ACTION_TYPE[:send_email])

      action.post_actions = Array(post_action1)
      action.add_post_action(post_action2)
      action.post_actions.should.nil?
      action.xml_element.elements['PostActions'].should.nil?
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::AnalyzeAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end
  end
end
