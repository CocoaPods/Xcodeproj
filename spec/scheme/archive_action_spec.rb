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

      describe 'custom_archive_name' do
        it '#custom_archive_name' do
          @sut.xml_element.attributes['customArchiveName'] = 'Foo'
          @sut.custom_archive_name.should == 'Foo'
        end

        it '#custom_archive_name= sets a new name' do
          @sut.custom_archive_name = 'Bar'
          @sut.xml_element.attributes['customArchiveName'].should == 'Bar'
        end

        it '#custom_archive_name= removes custom name' do
          @sut.custom_archive_name = nil
          @sut.xml_element.attributes['customArchiveName'].should.nil?
        end
      end
    end
  end
end
