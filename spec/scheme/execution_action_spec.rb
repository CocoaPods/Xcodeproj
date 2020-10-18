require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::ExecutionAction do
    describe 'Created from scratch' do
      it 'Creates an initial, almost empty XML node' do
        action = Xcodeproj::XCScheme::ExecutionAction.new(Constants::EXECUTION_ACTION_TYPE[:shell_script])
        action.xml_element.name.should == 'ExecutionAction'
        action.xml_element.attributes.count.should == 1
        action.xml_element.attributes['ActionType'].should == Constants::EXECUTION_ACTION_TYPE[:shell_script]
        action.xml_element.elements.count.should == 0
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('ExecutionAction')
        attributes = {
          'ActionType' => Constants::EXECUTION_ACTION_TYPE[:shell_script],
        }
        action_content_node = REXML::Element.new('ActionContent')
        node.add_attributes(attributes)
        node.add_element(action_content_node)
        @action = Xcodeproj::XCScheme::ExecutionAction.new(nil, node)
      end

      it 'raises if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::ExecutionAction.new(nil, node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#action_type' do
        @action.action_type.should == @action.xml_element.attributes['ActionType']
      end
    end
  end
end
