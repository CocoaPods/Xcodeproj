require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../xcscheme_spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::AnalyzeAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::AnalyzeAction.new(nil)
      action.xml_element.name.should == 'AnalyzeAction'
      action.xml_element.attributes.count.should == 1
      action.xml_element.attributes['buildConfiguration'].should == 'Debug'
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::AnalyzeAction.new(XCSchemeStub.new, node)
      end.message.should.match /Wrong XML tag name/
    end
  end
end
