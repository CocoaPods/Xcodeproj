require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::LocationScenarioReference do
    describe 'Created from scratch' do
      before do
        @ref = Xcodeproj::XCScheme::LocationScenarioReference.new(nil)
      end

      it 'Creates an initial, quite empty XML node' do
        @ref.xml_element.name.should == 'LocationScenarioReference'
        @ref.xml_element.attributes.count.should == 2
        @ref.xml_element.attributes['identifier'].should == ''
        @ref.xml_element.attributes['referenceType'].should == '0'
      end
    end

    describe 'Built-in Created from a XML node' do
      before do
        node = REXML::Element.new('LocationScenarioReference')
        attributes = {
          'identifier' => 'London, England',
          'referenceType' => '1',
        }
        node.add_attributes(attributes)
        @ref = Xcodeproj::XCScheme::LocationScenarioReference.new(node)
      end

      it 'raise if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::LocationScenarioReference.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#identifier' do
        @ref.identifier.should == @ref.xml_element.attributes['identifier']
      end

      it '#reference_type' do
        @ref.reference_type.should == @ref.xml_element.attributes['referenceType']
      end
    end

    describe 'Custom GPX Created from a XML node' do
      before do
        node = REXML::Element.new('LocationScenarioReference')
        attributes = {
          'identifier' => 'path/to/AmazingLocation.gpx',
          'referenceType' => '0',
        }
        node.add_attributes(attributes)
        @ref = Xcodeproj::XCScheme::LocationScenarioReference.new(node)
      end

      it 'raise if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::LocationScenarioReference.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#identifier' do
        @ref.identifier.should == @ref.xml_element.attributes['identifier']
      end

      it '#reference_type' do
        @ref.reference_type.should == @ref.xml_element.attributes['referenceType']
      end
    end
  end
end
