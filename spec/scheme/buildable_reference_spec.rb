require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::BuildableReference do
    describe 'Created from scratch' do
      before do
        @ref = Xcodeproj::XCScheme::BuildableReference.new(nil)
      end

      it 'Creates an initial, quite empty XML node' do
        @ref.xml_element.name.should == 'BuildableReference'
        @ref.xml_element.attributes.count.should == 1
        @ref.xml_element.attributes['BuildableIdentifier'].should == 'primary'
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('BuildableReference')
        attributes = {
          'BuildableIdentifier' => 'primary',
          'BuildableName' => 'FooApp.app',
          'BlueprintName' => 'SomeTargetName',
          'BlueprintIdentifier' => '0000-DEAD-BEAF-6666',
          'ReferencedContainer' => 'container:baz.xcodeproj',
        }
        node.add_attributes(attributes)
        @ref = Xcodeproj::XCScheme::BuildableReference.new(node)
      end

      it '#target_name' do
        @ref.target_name.should == @ref.xml_element.attributes['BlueprintName']
      end

      it '#target_uuid' do
        @ref.target_uuid.should == @ref.xml_element.attributes['BlueprintIdentifier']
      end

      it '#target_referenced_container' do
        @ref.target_referenced_container.should == @ref.xml_element.attributes['ReferencedContainer']
      end

      it '#buildable_name' do
        @ref.buildable_name.should == @ref.xml_element.attributes['BuildableName']
      end

      it '#buildable_name=' do
        @ref.buildable_name = 'Custom'
        @ref.xml_element.attributes['BuildableName'].should == 'Custom'
      end

      it '#set_reference_target without overriding buildable_name' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        other_target = project.new_target(:static_library, 'FooLib', :ios)
        @ref.set_reference_target(other_target, false)

        @ref.target_name.should == 'FooLib'
        @ref.target_uuid.should == other_target.uuid
        @ref.target_referenced_container.should == 'container:baz.xcodeproj'
        @ref.buildable_name.should == 'FooApp.app'
      end

      it '#set_reference_target with overriding of buildable_name' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        other_target = project.new_target(:static_library, 'FooLib', :ios)
        @ref.set_reference_target(other_target, true)

        @ref.target_name.should == 'FooLib'
        @ref.target_uuid.should == other_target.uuid
        @ref.target_referenced_container.should == 'container:baz.xcodeproj'
        @ref.buildable_name.should == 'libFooLib.a'
      end
    end

    describe 'Created from a target' do
      before do
        @project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @target = @project.new_target(:application, 'FooApp', :ios)
        @ref = Xcodeproj::XCScheme::BuildableReference.new(@target)
      end

      it 'Uses the proper XML node' do
        @ref.xml_element.name.should == 'BuildableReference'
      end

      it '#target_name' do
        @ref.target_name.should == @ref.xml_element.attributes['BlueprintName']
        @ref.target_name.should == @target.name
      end

      it '#target_uuid' do
        @ref.target_uuid.should == @ref.xml_element.attributes['BlueprintIdentifier']
        @ref.target_uuid.should == @target.uuid
      end

      it '#target_referenced_container' do
        @ref.target_referenced_container.should == @ref.xml_element.attributes['ReferencedContainer']
        @ref.target_referenced_container.should == 'container:baz.xcodeproj'
      end

      it '#buildable_name' do
        @ref.buildable_name.should == @ref.xml_element.attributes['BuildableName']
        @ref.buildable_name.should == 'FooApp.app'
      end

      it '#buildable_name=' do
        @ref.buildable_name = 'Custom'
        @ref.xml_element.attributes['BuildableName'].should == 'Custom'
      end

      it '#set_reference_target without overriding buildable_name' do
        other_target = @project.new_target(:static_library, 'FooLib', :ios)
        @ref.set_reference_target(other_target, false)

        @ref.target_name.should == 'FooLib'
        @ref.target_uuid.should == other_target.uuid
        @ref.target_referenced_container.should == 'container:baz.xcodeproj'
        @ref.buildable_name.should == 'FooApp.app'
      end

      it '#set_reference_target with overriding of buildable_name' do
        other_target = @project.new_target(:static_library, 'FooLib', :ios)
        @ref.set_reference_target(other_target, true)

        @ref.target_name.should == 'FooLib'
        @ref.target_uuid.should == other_target.uuid
        @ref.target_referenced_container.should == 'container:baz.xcodeproj'
        @ref.buildable_name.should == 'libFooLib.a'
      end
    end
  end
end
