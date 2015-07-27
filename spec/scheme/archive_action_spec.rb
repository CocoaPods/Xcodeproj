require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::ArchiveAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::ArchiveAction.new(nil)
      action.xml_element.name.should == 'ArchiveAction'
      action.xml_element.attributes.count.should == 2
      action.xml_element.attributes['revealArchiveInOrganizer'].should == 'YES'
      action.xml_element.attributes['buildConfiguration'].should == 'Release'
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::ArchiveAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('ArchiveAction')
        @sut = Xcodeproj::XCScheme::ArchiveAction.new(node)
      end

      extend SpecHelper::XCScheme
      specs_for_bool_attr(:reveal_archive_in_organizer => 'revealArchiveInOrganizer')

      xit '#custom_archive_name' do
        # @todo
      end

      xit '#custom_archive_name=' do
        # @todo
      end
    end
  end
end
