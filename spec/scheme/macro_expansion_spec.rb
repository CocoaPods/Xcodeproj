require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../xcscheme_spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::MacroExpansion do
    describe 'Created from scratch' do
      before do
        @macro_exp = Xcodeproj::XCScheme::MacroExpansion.new(XCSchemeStub.new, nil)
      end

      it 'Creates an initial, empty XML node' do
        @macro_exp.xml_element.name.should == 'MacroExpansion'
        @macro_exp.xml_element.attributes.count.should == 0
        @macro_exp.xml_element.elements.count.should == 0
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('MacroExpansion')
        ref = REXML::Element.new('BuildableReference')
        node.add_element(ref)
        @macro_exp = Xcodeproj::XCScheme::MacroExpansion.new(XCSchemeStub.new, node)
      end

      it 'raises if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::MacroExpansion.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#buildable_reference' do
        @macro_exp.buildable_reference.xml_element.should == @macro_exp.xml_element.elements['BuildableReference']
      end

      it '#buildable_reference=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(@macro_exp.scheme, nil)
        @macro_exp.buildable_reference = other_ref
        @macro_exp.xml_element.elements.count.should == 1
        @macro_exp.xml_element.elements['BuildableReference'].should == other_ref.xml_element
      end
    end

    describe 'Created from a target' do
      before do
        @project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @target = @project.new_target(:application, 'FooApp', :ios)
        @macro_exp = Xcodeproj::XCScheme::MacroExpansion.new(XCSchemeStub.new, @target)
      end

      it 'Uses the proper XML node' do
        @macro_exp.xml_element.name.should == 'MacroExpansion'
      end

      it '#buildable_reference' do
        @macro_exp.buildable_reference.xml_element.should == @macro_exp.xml_element.elements['BuildableReference']
      end

      it '#buildable_name=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(XCSchemeStub.new, nil)
        @macro_exp.buildable_reference = other_ref
        @macro_exp.xml_element.elements.count.should == 1
        @macro_exp.xml_element.elements['BuildableReference'].should == other_ref.xml_element
      end
    end
  end
end
