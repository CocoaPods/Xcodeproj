require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::XMLElementWrapper do
    before do
      @wrapper = Xcodeproj::XCScheme::XMLElementWrapper.new
    end

    describe '#create_xml_element_with_fallback' do
      it 'uses node when tag match' do
        node = REXML::Element.new('Expected')
        @wrapper.create_xml_element_with_fallback(node, 'Expected') do
          raise 'Block should not be executed'
        end
        @wrapper.xml_element.should == node
      end

      it 'raise when tag mismatch' do
        node = REXML::Element.new('BadTagName')
        should.raise Xcodeproj::Informative do
          @wrapper.create_xml_element_with_fallback(node, 'Expected')
        end.message.should.match /Wrong XML tag name/
        @wrapper.xml_element.should.nil?
      end

      it 'create a new node when target is not a node itself' do
        block_executed = false
        @wrapper.create_xml_element_with_fallback('NotANode', 'Expected') do
          block_executed = true
        end
        @wrapper.xml_element.class.should == REXML::Element
        @wrapper.xml_element.name.should == 'Expected'
        block_executed.should == true
      end

      it 'accept nil input and no block' do
        @wrapper.create_xml_element_with_fallback(nil, 'Expected')
        @wrapper.xml_element.class.should == REXML::Element
        @wrapper.xml_element.name.should == 'Expected'
      end
    end

    describe '#bool_to_string' do
      it 'returns YES when true' do
        @wrapper.instance_eval { bool_to_string(true) }.should == 'YES'
      end

      it 'returns NO when false' do
        @wrapper.instance_eval { bool_to_string(false) }.should == 'NO'
      end
    end

    describe '#string_to_bool' do
      it 'returns true when YES' do
        @wrapper.instance_eval { string_to_bool('YES') }.should == true
      end

      it 'returns false when NO' do
        @wrapper.instance_eval { string_to_bool('NO') }.should == false
      end

      it 'raises when unknown string' do
        should.raise Xcodeproj::Informative do
          @wrapper.instance_eval { string_to_bool('Meh') }
        end.message.should.match /Invalid tag value. Expected YES or NO./
      end
    end
  end
end
