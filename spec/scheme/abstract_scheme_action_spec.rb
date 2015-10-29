require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::AbstractSchemeAction do
    before do
      @action = Xcodeproj::XCScheme::AbstractSchemeAction.new
      @action.instance_eval { @xml_element = REXML::Element.new('Foo') }
    end

    describe '#build_configuration' do
      it 'get the value if it exists' do
        @action.xml_element.attributes['buildConfiguration'] = 'Bar'
        @action.build_configuration.should == 'Bar'
      end

      it 'return nil if it does not exist' do
        @action.build_configuration.should.nil?
      end

      it 'sets the value' do
        @action.build_configuration = 'Baz'
        @action.xml_element.attributes['buildConfiguration'].should == 'Baz'
      end
    end
  end
end
