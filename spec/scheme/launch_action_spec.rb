require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::LaunchAction do
    it 'Creates a default XML node when created from scratch' do
      action = Xcodeproj::XCScheme::LaunchAction.new(nil)
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
      action.xml_element.attributes['disableMainThreadChecker'].nil?
      action.xml_element.attributes['stopOnEveryMainThreadCheckerIssue'].nil?
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::LaunchAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('LaunchAction')
        @sut = Xcodeproj::XCScheme::LaunchAction.new(node)
      end

      extend SpecHelper::XCScheme
      specs_for_bool_attr(:allow_location_simulation => 'allowLocationSimulation')

      describe 'launch_automatically_substyle' do
        it '#launch_automatically_substyle=' do
          @sut.launch_automatically_substyle = '2'
          @sut.xml_element.attributes['launchAutomaticallySubstyle'].should == '2'
        end
      end

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

      describe '#command_line_arguments' do
        vars_node_name = XCScheme::COMMAND_LINE_ARGS_NODE
        var_node_name = XCScheme::COMMAND_LINE_ARG_NODE

        it 'starts as nil if no xml exists' do
          @sut.xml_element.elements[vars_node_name].should.equal nil
          @sut.command_line_arguments.to_a.should.equal []
        end

        it 'picks up an existing node if exists in the XML' do
          env_vars_xml = @sut.xml_element.add_element(vars_node_name)
          env_vars_xml.add_element(var_node_name, 'isEnabled' => 'NO', 'argument' => '-com.foo.bar 1')
          env_vars_xml.add_element(var_node_name, 'isEnabled' => 'YES', 'argument' => '-org.foo.bar 1')

          # Reload content from XML
          @sut = XCScheme::LaunchAction.new(@sut.xml_element)

          @sut.command_line_arguments.to_a.should == [{ :argument => '-com.foo.bar 1', :enabled => false },
                                                      { :argument => '-org.foo.bar 1', :enabled => true }]
        end

        it 'reflects direct changes to xml' do
          @sut.command_line_arguments = XCScheme::CommandLineArguments.new([{ :argument => '-com.foo.bar 1', :enabled => false },
                                                                            { :argument => '-org.foo.bar 1', :enabled => true }])
          node_to_delete = @sut.command_line_arguments.xml_element.elements["#{var_node_name}[@argument='-com.foo.bar 1']"]
          @sut.command_line_arguments.xml_element.delete(node_to_delete)
          @sut.command_line_arguments.to_a.should == [{ :argument => '-org.foo.bar 1', :enabled => true }]
        end

        it 'can be assigned nil' do
          @sut.xml_element.get_elements(vars_node_name).count.should == 0

          @sut.command_line_arguments = XCScheme::CommandLineArguments.new
          @sut.command_line_arguments.should.not.equal nil
          @sut.xml_element.get_elements(vars_node_name).count.should == 1

          @sut.command_line_arguments = nil
          @sut.command_line_arguments.to_a.should.equal []
          @sut.xml_element.elements[vars_node_name].should.be.nil
        end

        it 'assigning an CommandLineArguments object updates the xml' do
          cl_arg = XCScheme::CommandLineArguments.new([{ :argument => '-com.foo.bar 1', :enabled => false }])
          cl_arg.xml_element.elements.count.should == 1

          @sut.command_line_arguments = cl_arg
          @sut.command_line_arguments.to_a.should == [{ :argument => '-com.foo.bar 1', :enabled => false }]
          @sut.command_line_arguments.xml_element.should == cl_arg.xml_element

          xml_out = ''
          xml_formatter = REXML::Formatters::Pretty.new(0)
          xml_formatter.compact = true
          xml_formatter.write(@sut.command_line_arguments.xml_element, xml_out)
          xml_out.should == "<CommandLineArguments>\n<CommandLineArgument argument='-com.foo.bar 1' isEnabled='NO'/>\n</CommandLineArguments>"
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
          @sut = XCScheme::LaunchAction.new(@sut.xml_element)

          @sut.environment_variables.to_a.should == [{ :key => 'a', :value => '1', :enabled => true },
                                                     { :key => 'b', :value => '2', :enabled => false }]
        end

        it 'reflects direct changes to xml' do
          @sut.environment_variables = XCScheme::EnvironmentVariables.new([{ :key => 'a', :value => '1', :enabled => false },
                                                                           { :key => 'b', :value => '2', :enabled => true },
                                                                           { :key => 'c', :value => '3', :enabled => true }])
          node_to_delete = @sut.environment_variables.xml_element.elements["#{var_node_name}[@key='b']"]
          @sut.environment_variables.xml_element.delete(node_to_delete)
          @sut.environment_variables.to_a.should == [{ :key => 'a', :value => '1', :enabled => false },
                                                     { :key => 'c', :value => '3', :enabled => true }]
        end

        it 'can be assigned nil' do
          @sut.xml_element.get_elements(vars_node_name).count.should == 0

          @sut.environment_variables = XCScheme::EnvironmentVariables.new
          @sut.environment_variables.should.not.equal nil
          @sut.xml_element.get_elements(vars_node_name).count.should == 1

          @sut.environment_variables = nil
          @sut.environment_variables.to_a.should.equal []
          @sut.xml_element.elements[vars_node_name].should.be.nil
        end

        it 'assigning an EnvironmentVariables object updates the xml' do
          env_var = Xcodeproj::XCScheme::EnvironmentVariables.new([{ :key => 'a', :value => '1' }])
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

      it '#macro_expansions' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        macro1 = XCScheme::MacroExpansion.new(target1)
        @sut.xml_element.add_element(macro1.xml_element)

        target2 = project.new_target(:application, 'FooApp', :ios)
        macro2 = XCScheme::MacroExpansion.new(target2)
        @sut.xml_element.add_element(macro2.xml_element)

        @sut.macro_expansions.count.should == 2
        @sut.macro_expansions.all? { |m| m.class.should == XCScheme::MacroExpansion }
        @sut.macro_expansions[0].xml_element.should == macro1.xml_element
        @sut.macro_expansions[1].xml_element.should == macro2.xml_element
      end

      it '#add_macro_expansion' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        macro1 = XCScheme::MacroExpansion.new(target1)
        @sut.add_macro_expansion(macro1)

        target2 = project.new_target(:application, 'FooApp', :ios)
        macro2 = XCScheme::MacroExpansion.new(target2)
        @sut.add_macro_expansion(macro2)

        @sut.xml_element.get_elements('MacroExpansion').count.should == 2
        @sut.xml_element.elements['MacroExpansion[1]'].should == macro1.xml_element
        @sut.xml_element.elements['MacroExpansion[2]'].should == macro2.xml_element
      end
    end
  end
end
