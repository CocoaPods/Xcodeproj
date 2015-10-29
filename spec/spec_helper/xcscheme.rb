module SpecHelper
  module XCScheme
    def specs_for_bool_attr(attributes_map)
      attributes_map.each do |property, xml_attribute_name|
        attr_reader_sym = (property.to_s + '?').to_sym
        attr_writer_sym = (property.to_s + '=').to_sym

        describe property do
          it "##{property}? detect a true value" do
            @sut.xml_element.attributes[xml_attribute_name] = 'YES'
            @sut.send(attr_reader_sym).should == true
          end

          it "##{property}? detect a false value" do
            @sut.xml_element.attributes[xml_attribute_name] = 'NO'
            @sut.send(attr_reader_sym).should == false
          end

          it "##{property}? detect an invalid value" do
            @sut.xml_element.attributes[xml_attribute_name] = 'BadValue'
            should.raise(Xcodeproj::Informative) { @sut.send(attr_reader_sym) }
          end

          it "##{property}= set true value" do
            @sut.send(attr_writer_sym, true)
            @sut.xml_element.attributes[xml_attribute_name].should == 'YES'
          end

          it "##{property}= set false value" do
            @sut.send(attr_writer_sym, false)
            @sut.xml_element.attributes[xml_attribute_name].should == 'NO'
          end
        end
      end
    end
  end
end
