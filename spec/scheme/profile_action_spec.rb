require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::ProfileAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::ProfileAction.new(nil)
      action.xml_element.name.should == 'ProfileAction'
      action.xml_element.attributes.count.should == 5
      action.xml_element.attributes['savedToolIdentifier'].should == ''
      action.xml_element.attributes['useCustomWorkingDirectory'].should == 'NO'
      action.xml_element.attributes['debugDocumentVersioning'].should == 'YES'
      action.xml_element.attributes['shouldUseLaunchSchemeArgsEnv'].should == 'YES'
      action.xml_element.attributes['buildConfiguration'].should == 'Release'
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::ProfileAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('ProfileAction')
        @sut = Xcodeproj::XCScheme::ProfileAction.new(node)
      end

      extend SpecHelper::XCScheme
      specs_for_bool_attr(:should_use_launch_scheme_args_env => 'shouldUseLaunchSchemeArgsEnv')

      describe 'buildable_product_runnable' do
        it '#buildable_product_runnable' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
          target = project.new_target(:application, 'FooApp', :ios)
          bpr = XCScheme::BuildableProductRunnable.new(target)

          node = bpr.xml_element
          @sut.xml_element.elements['BuildableProductRunnable'] = node
          @sut.buildable_product_runnable.class.should == XCScheme::BuildableProductRunnable
          @sut.buildable_product_runnable.xml_element.should == node
        end

        it '#buildable_product_runnable=' do
          project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
          target = project.new_target(:application, 'FooApp', :ios)
          bpr = XCScheme::BuildableProductRunnable.new(target)

          @sut.buildable_product_runnable = bpr
          @sut.xml_element.elements['BuildableProductRunnable'].should == bpr.xml_element
        end
      end
    end
  end
end
