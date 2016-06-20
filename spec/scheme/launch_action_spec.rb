require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../xcscheme_spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::LaunchAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::LaunchAction.new(XCSchemeStub.new, nil)
      action.xml_element.name.should == 'LaunchAction'
      action.xml_element.attributes.count.should == 9
      action.xml_element.attributes['selectedDebuggerIdentifier'].should == 'Xcode.DebuggerFoundation.Debugger.LLDB'
      action.xml_element.attributes['selectedLauncherIdentifier'].should == 'Xcode.DebuggerFoundation.Launcher.LLDB'
      action.xml_element.attributes['launchStyle'].should == '0'
      action.xml_element.attributes['useCustomWorkingDirectory'].should == 'NO'
      action.xml_element.attributes['ignoresPersistentStateOnLaunch'].should == 'NO'
      action.xml_element.attributes['debugDocumentVersioning'].should == 'YES'
      action.xml_element.attributes['debugServiceExtension'].should == 'internal'
      action.xml_element.attributes['buildConfiguration'].should == 'Debug'
      action.xml_element.attributes['allowLocationSimulation'].should == 'YES'
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::LaunchAction.new(XCSchemeStub.new, node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('LaunchAction')
        @scheme = XCScheme.new
        @scheme.set_bundle_path_and_name('/tmp/foo/bar/baz.xcodeproj', 'TestScheme')
        @sut = Xcodeproj::XCScheme::LaunchAction.new(@scheme, node)
      end

      extend SpecHelper::XCScheme
      specs_for_bool_attr(:allow_location_simulation => 'allowLocationSimulation')

      describe 'buildable_product_runnable' do
        it '#buildable_product_runnable' do
          project = Xcodeproj::Project.new('/tmp/foo/bar/baz.xcodeproj')
          target = project.new_target(:application, 'FooApp', :ios)
          bpr = XCScheme::BuildableProductRunnable.new(@sut.scheme, target)

          node = bpr.xml_element
          @sut.xml_element.elements['BuildableProductRunnable'] = node
          @sut.buildable_product_runnable.class.should == XCScheme::BuildableProductRunnable
          @sut.buildable_product_runnable.xml_element.should == node
        end

        it '#buildable_product_runnable=' do
          project = Xcodeproj::Project.new('/tmp/foo/bar/baz.xcodeproj')
          target = project.new_target(:application, 'FooApp', :ios)
          bpr = XCScheme::BuildableProductRunnable.new(@sut.scheme, target)

          @sut.buildable_product_runnable = bpr
          @sut.xml_element.elements['BuildableProductRunnable'].should == bpr.xml_element
        end
      end

      describe '#environment_variables' do
        vars_node_name = XCScheme::VARIABLES_NODE
        var_node_name = XCScheme::VARIABLE_NODE

        it 'starts as nil if no xml exists' do
          @sut.xml_element.elements[vars_node_name].should.equal nil
          @sut.environment_variables.to_a.should.equal []
        end

        it 'picks up an existing node if exists in the XML' do
          env_vars_xml = @sut.xml_element.add_element(vars_node_name)
          env_vars_xml.add_element(var_node_name, 'isEnabled' => 'YES', 'key' => 'a', 'value' => '1')
          env_vars_xml.add_element(var_node_name, 'isEnabled' => 'NO', 'key' => 'b', 'value' => '2')

          # Reload content from XML
          @sut = XCScheme::LaunchAction.new(@sut.scheme, @sut.xml_element)
          print @sut.environment_variables.to_a
          @sut.environment_variables.to_a.should == [{ :key => 'a', :value => '1', :enabled => true },
                                                     { :key => 'b', :value => '2', :enabled => false }]
        end

        it 'reflects direct changes to xml' do
          @sut.environment_variables = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'a', :value => '1', :enabled => false },
                                                                                        { :key => 'b', :value => '2', :enabled => true },
                                                                                        { :key => 'c', :value => '3', :enabled => true }])
          node_to_delete = @sut.environment_variables.xml_element.elements["#{var_node_name}[@key='b']"]
          @sut.environment_variables.xml_element.delete(node_to_delete)
          @sut.environment_variables.to_a.should == [{ :key => 'a', :value => '1', :enabled => false },
                                                     { :key => 'c', :value => '3', :enabled => true }]
        end

        it 'can be assigned nil' do
          @sut.xml_element.get_elements(vars_node_name).count.should == 0

          @sut.environment_variables = XCScheme::EnvironmentVariables.new(@sut.scheme)
          @sut.environment_variables.should.not.equal nil
          @sut.xml_element.get_elements(vars_node_name).count.should == 1

          @sut.environment_variables = nil
          @sut.environment_variables.to_a.should.equal []
          @sut.xml_element.elements[vars_node_name].should.be.nil
        end

        it 'assigning an EnvironmentVariables object updates the xml' do
          env_var = Xcodeproj::XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'a', :value => '1' }])
          env_var.xml_element.elements.count.should == 1

          @sut.environment_variables = env_var
          @sut.environment_variables.to_a.should == [{ :key => 'a', :value => '1', :enabled => true }]
          @sut.environment_variables.xml_element.should == env_var.xml_element

          xml_out = ''
          xml_formatter = REXML::Formatters::Pretty.new(0)
          xml_formatter.compact = true
          xml_formatter.write(@sut.environment_variables.xml_element, xml_out)
          xml_out.should == "<EnvironmentVariables>\n<EnvironmentVariable key='a' value='1' isEnabled='YES'/>\n</EnvironmentVariables>"
        end
      end
    end
  end
end
