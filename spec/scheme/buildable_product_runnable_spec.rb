require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../xcscheme_spec_helper', __FILE__)


module Xcodeproj
  describe XCScheme::BuildableProductRunnable do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
      end

      describe 'Created from scratch' do
      it 'Creates an initial, empty XML node' do
        bpr = Xcodeproj::XCScheme::BuildableProductRunnable.new(@sut.scheme.bundle_path, nil)
        bpr.xml_element.name.should == 'BuildableProductRunnable'
        bpr.xml_element.attributes.count.should == 0
        bpr.xml_element.elements.count.should == 0
      end

      it 'Creates an initial, empty XML node with runnableDebuggingMode' do
        bpr = Xcodeproj::XCScheme::BuildableProductRunnable.new(@sut.scheme.bundle_path, nil, 1)
        bpr.xml_element.name.should == 'BuildableProductRunnable'
        bpr.xml_element.attributes.count.should == 1
        bpr.xml_element.attributes['runnableDebuggingMode'].should == '1'
        bpr.xml_element.elements.count.should == 0
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('BuildableProductRunnable')
        ref = REXML::Element.new('BuildableReference')
        node.add_element(ref)
        @bpr = Xcodeproj::XCScheme::BuildableProductRunnable.new(@sut.scheme.bundle_path, node)
      end

      it 'raises if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::BuildableProductRunnable.new(@sut.scheme.bundle_path, node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#buildable_reference' do
        @bpr.buildable_reference.xml_element.should == @bpr.xml_element.elements['BuildableReference']
      end

      it '#buildable_reference=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(@sut.scheme, nil)
        @bpr.buildable_reference = other_ref
        @bpr.xml_element.elements.count.should == 1
        @bpr.xml_element.elements['BuildableReference'].should == other_ref.xml_element
      end
    end

    describe 'Created from a target' do
      before do
        @project = Xcodeproj::Project.new('/tmp/foo/bar/baz.xcodeproj')
        @target = @project.new_target(:application, 'FooApp', :ios)
        @bpr = Xcodeproj::XCScheme::BuildableProductRunnable.new(@sut.scheme, @target)
      end

      it 'Uses the proper XML node' do
        @bpr.xml_element.name.should == 'BuildableProductRunnable'
      end

      it '#buildable_reference' do
        @bpr.buildable_reference.xml_element.should == @bpr.xml_element.elements['BuildableReference']
      end

      it '#buildable_name=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(@sut.scheme, nil)
        @bpr.buildable_reference = other_ref
        @bpr.xml_element.elements.count.should == 1
        @bpr.xml_element.elements['BuildableReference'].should == other_ref.xml_element
      end
    end
  end
end
