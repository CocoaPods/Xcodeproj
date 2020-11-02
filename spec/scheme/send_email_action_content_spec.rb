require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::SendEmailActionContent do
    describe 'Created from scratch' do
      it 'Creates an initial, almost empty XML node' do
        sut = Xcodeproj::XCScheme::SendEmailActionContent.new
        sut.xml_element.name.should == 'ActionContent'
        sut.xml_element.attributes.count.should == 2
        sut.xml_element.attributes['title'].should == 'Send Email'
        sut.attach_log_to_email?.should == false
        sut.xml_element.elements.count.should == 0
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('ActionContent')
        attributes = {
          'title' => 'Foo Title',
          'emailRecipient' => 'Foo email',
          'emailSubject' => 'Foo subject',
          'emailBody' => 'Foo body',
          'attachLogToEmail' => 'NO',
        }
        node.add_attributes(attributes)
        @sut = Xcodeproj::XCScheme::SendEmailActionContent.new(node)
      end

      it 'raises if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::SendEmailActionContent.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#title' do
        @sut.title.should == @sut.xml_element.attributes['title']
      end

      it '#title=' do
        @sut.title = 'Foo'
        @sut.xml_element.attributes['title'].should == 'Foo'
      end

      it '#email_recipient' do
        @sut.email_recipient.should == @sut.xml_element.attributes['emailRecipient']
      end

      it '#email_recipient=' do
        @sut.email_recipient = 'Foo'
        @sut.xml_element.attributes['emailRecipient'].should == 'Foo'
      end

      it '#email_subject' do
        @sut.email_subject.should == @sut.xml_element.attributes['emailSubject']
      end

      it '#email_subject=' do
        @sut.email_subject = 'Foo'
        @sut.xml_element.attributes['emailSubject'].should == 'Foo'
      end

      it '#email_body' do
        @sut.email_body.should == @sut.xml_element.attributes['emailBody']
      end

      it '#email_body=' do
        @sut.email_body = 'Foo'
        @sut.xml_element.attributes['emailBody'].should == 'Foo'
      end
    end
  end
end
