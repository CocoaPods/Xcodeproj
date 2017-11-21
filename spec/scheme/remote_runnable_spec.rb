require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::RemoteRunnable do
    describe 'Created from scratch' do
      it 'Creates an initial, empty XML node' do
        bpr = Xcodeproj::XCScheme::RemoteRunnable.new(nil)
        bpr.xml_element.name.should == 'RemoteRunnable'
        bpr.xml_element.attributes.count.should == 0
        bpr.xml_element.elements.count.should == 0
      end

      it 'Creates an initial, empty XML node with runnableDebuggingMode' do
        bpr = Xcodeproj::XCScheme::RemoteRunnable.new(nil, 2)
        bpr.xml_element.name.should == 'RemoteRunnable'
        bpr.xml_element.attributes.count.should == 1
        bpr.xml_element.attributes['runnableDebuggingMode'].should == '2'
        bpr.xml_element.elements.count.should == 0
      end

      it 'Creates an initial, empty XML node with BundleIdentifier' do
        bpr = Xcodeproj::XCScheme::RemoteRunnable.new(nil, nil, 'com.apple.Carousel')
        bpr.xml_element.name.should == 'RemoteRunnable'
        bpr.xml_element.attributes.count.should == 1
        bpr.xml_element.attributes['BundleIdentifier'].should == 'com.apple.Carousel'
        bpr.xml_element.elements.count.should == 0
      end

      it 'Creates an initial, empty XML node with RemotePath' do
        bpr = Xcodeproj::XCScheme::RemoteRunnable.new(nil, nil, nil, '/Test')
        bpr.xml_element.name.should == 'RemoteRunnable'
        bpr.xml_element.attributes.count.should == 1
        bpr.xml_element.attributes['RemotePath'].should == '/Test'
        bpr.xml_element.elements.count.should == 0
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('RemoteRunnable')
        ref = REXML::Element.new('BuildableReference')
        node.add_element(ref)
        @bpr = Xcodeproj::XCScheme::RemoteRunnable.new(node)
      end

      it 'raises if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::RemoteRunnable.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#buildable_reference' do
        @bpr.buildable_reference.xml_element.should == @bpr.xml_element.elements['BuildableReference']
      end

      it '#buildable_reference=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(nil)
        @bpr.buildable_reference = other_ref
        @bpr.xml_element.elements.count.should == 1
        @bpr.xml_element.elements['BuildableReference'].should == other_ref.xml_element
      end
    end

    describe 'Created from a target' do
      before do
        @project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @target = @project.new_target(:application, 'FooApp', :ios)
        @bpr = Xcodeproj::XCScheme::RemoteRunnable.new(@target)
      end

      it 'Uses the proper XML node' do
        @bpr.xml_element.name.should == 'RemoteRunnable'
      end

      it '#buildable_reference' do
        @bpr.buildable_reference.xml_element.should == @bpr.xml_element.elements['BuildableReference']
      end

      it '#buildable_name=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(nil)
        @bpr.buildable_reference = other_ref
        @bpr.xml_element.elements.count.should == 1
        @bpr.xml_element.elements['BuildableReference'].should == other_ref.xml_element
      end
    end
  end
end
