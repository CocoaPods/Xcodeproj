module SpecHelper
  module XCScheme
    def specs_for_bool_attr(attributes_map)
      attributes_map.each do |property, xml_attribute_name|
        it "##{property.to_s}?" do
          attr_reader_sym = (property.to_s+'?').to_sym
          @sut.xml_element.attributes[xml_attribute_name] = 'YES'
          @sut.send(attr_reader_sym).should == true
          
          @sut.xml_element.attributes[xml_attribute_name] = 'NO'
          @sut.send(attr_reader_sym).should == false
          
          @sut.xml_element.attributes[xml_attribute_name] = 'BadValue'
          should.raise(Xcodeproj::Informative) { @sut.send(attr_reader_sym) }
        end

        it "##{property.to_s}=" do
          attr_writer_sym = (property.to_s+'=').to_sym
          @sut.send(attr_writer_sym, true)
          @sut.xml_element.attributes[xml_attribute_name].should == 'YES'
          @sut.send(attr_writer_sym, false)
          @sut.xml_element.attributes[xml_attribute_name].should == 'NO'
        end
      end
    end
  end
end
