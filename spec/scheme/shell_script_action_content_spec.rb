require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::ShellScriptActionContent do
    describe 'Created from scratch' do
      it 'Creates an initial, almost empty XML node' do
        sut = Xcodeproj::XCScheme::ShellScriptActionContent.new
        sut.xml_element.name.should == 'ActionContent'
        sut.xml_element.attributes.count.should == 1
        sut.xml_element.attributes['title'].should == 'Run Script'
        sut.xml_element.elements.count.should == 0
      end
    end

    describe 'Created from a XML node' do
      before do
        node = REXML::Element.new('ActionContent')
        attributes = {
          'title' => 'Foo Title',
          'scriptText' => 'Foo code',
          'shellToInvoke' => 'Foo shell',
        }
        env_buildable = REXML::Element.new('EnvironmentBuildable')
        env_buildable.add_element('BuildableReference')

        node.add_attributes(attributes)
        node.add_element(env_buildable)
        @sut = Xcodeproj::XCScheme::ShellScriptActionContent.new(node)
      end

      it 'raises if invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::ShellScriptActionContent.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it '#title' do
        @sut.title.should == @sut.xml_element.attributes['title']
      end

      it '#title=' do
        @sut.title = 'Foo'
        @sut.xml_element.attributes['title'].should == 'Foo'
      end

      it '#script_text' do
        @sut.script_text.should == @sut.xml_element.attributes['scriptText']
      end

      it '#script_text=' do
        @sut.script_text = 'Foo'
        @sut.xml_element.attributes['scriptText'].should == 'Foo'
      end

      it '#shell_to_invoke' do
        @sut.shell_to_invoke.should == @sut.xml_element.attributes['shellToInvoke']
      end

      it '#shell_to_invoke=' do
        @sut.shell_to_invoke = 'Foo'
        @sut.xml_element.attributes['shellToInvoke'].should == 'Foo'
      end

      it '#buildable_reference' do
        @sut.buildable_reference.xml_element.should == @sut.xml_element.elements['EnvironmentBuildable'].elements['BuildableReference']
      end

      it '#buildable_reference=' do
        other_ref = Xcodeproj::XCScheme::BuildableReference.new(nil)
        @sut.buildable_reference = other_ref
        @sut.xml_element.elements.count.should == 1
        @sut.xml_element.elements['EnvironmentBuildable'].elements['BuildableReference'].should == other_ref.xml_element
      end
    end
  end
end
