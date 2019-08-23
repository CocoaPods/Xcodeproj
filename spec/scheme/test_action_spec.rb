require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  describe XCScheme::TestAction do
    it 'Creates a default XML node when created from scratch' do
      test_action = Xcodeproj::XCScheme::TestAction.new(nil)
      test_action.xml_element.name.should == 'TestAction'
      test_action.xml_element.attributes.count.should == 4
      test_action.xml_element.attributes['selectedDebuggerIdentifier'].should == 'Xcode.DebuggerFoundation.Debugger.LLDB'
      test_action.xml_element.attributes['selectedLauncherIdentifier'].should == 'Xcode.DebuggerFoundation.Launcher.LLDB'
      test_action.xml_element.attributes['shouldUseLaunchSchemeArgsEnv'].should == 'YES'
      test_action.xml_element.attributes['buildConfiguration'].should == 'Debug'
      test_action.xml_element.attributes['disableMainThreadChecker'].nil?
    end

    it 'raises if created with an invalid XML node' do
      node = REXML::Element.new('Foo')
      should.raise(Informative) do
        Xcodeproj::XCScheme::TestAction.new(node)
      end.message.should.match /Wrong XML tag name/
    end

    describe 'Map attributes to XML' do
      before do
        node = REXML::Element.new('TestAction')
        @sut = Xcodeproj::XCScheme::TestAction.new(node)
      end

      extend SpecHelper::XCScheme
      specs_for_bool_attr(:should_use_launch_scheme_args_env => 'shouldUseLaunchSchemeArgsEnv')
      specs_for_bool_attr(:code_coverage_enabled => 'codeCoverageEnabled')
      specs_for_bool_attr(:disable_main_thread_checker => 'disableMainThreadChecker')

      it '#testables' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @sut.xml_element.add_element('Testables')

        target1 = project.new_target(:application, 'FooApp', :ios)
        test_ref1 = XCScheme::TestAction::TestableReference.new(target1)
        @sut.xml_element.elements['Testables'].add_element(test_ref1.xml_element)

        target2 = project.new_target(:application, 'FooApp', :ios)
        test_ref2 = XCScheme::TestAction::TestableReference.new(target2)
        @sut.xml_element.elements['Testables'].add_element(test_ref2.xml_element)

        @sut.testables.count.should == 2
        @sut.testables.all? { |t| t.class.should == XCScheme::TestAction::TestableReference }
        @sut.testables[0].xml_element.should == test_ref1.xml_element
        @sut.testables[1].xml_element.should == test_ref2.xml_element
      end

      it '#testables=' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        test_ref1 = XCScheme::TestAction::TestableReference.new(target1)

        target2 = project.new_target(:application, 'FooApp', :ios)
        test_ref2 = XCScheme::TestAction::TestableReference.new(target2)

        @sut.testables = [test_ref1, test_ref2]

        @sut.testables.count.should == 2
        @sut.testables.all? { |t| t.class.should == XCScheme::TestAction::TestableReference }
        @sut.testables[0].xml_element.should == test_ref1.xml_element
        @sut.testables[1].xml_element.should == test_ref2.xml_element
      end

      it '#add_testables' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')

        target1 = project.new_target(:application, 'FooApp', :ios)
        test_ref1 = XCScheme::TestAction::TestableReference.new(target1)
        @sut.add_testable(test_ref1)

        target2 = project.new_target(:application, 'FooApp', :ios)
        test_ref2 = XCScheme::TestAction::TestableReference.new(target2)
        @sut.add_testable(test_ref2)

        @sut.xml_element.elements['Testables'].count.should == 2
        @sut.xml_element.elements['Testables/TestableReference[1]'].should == test_ref1.xml_element
        @sut.xml_element.elements['Testables/TestableReference[2]'].should == test_ref2.xml_element
      end

      it '#macro_expansions' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        @sut.xml_element.add_element('Testables')

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
          @sut = XCScheme::TestAction.new(@sut.xml_element)

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
          @sut = XCScheme::TestAction.new(@sut.xml_element)

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
    end

    describe XCScheme::TestAction::TestableReference do
      it 'Creates a default XML node when created from scratch' do
        test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(nil)

        test_ref.xml_element.name.should == 'TestableReference'
        test_ref.xml_element.attributes.count.should == 1
        test_ref.xml_element.attributes['skipped'].should == 'NO'
        test_ref.should.not.be.randomized?
      end

      it 'raises if created with an invalid XML node' do
        node = REXML::Element.new('Foo')
        should.raise(Informative) do
          Xcodeproj::XCScheme::TestAction::TestableReference.new(node)
        end.message.should.match /Wrong XML tag name/
      end

      it 'Uses the proper XML node when created from a target' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        target = project.new_target(:application, 'FooApp', :ios)
        test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(target)
        test_ref.xml_element.name.should == 'TestableReference'
      end

      describe 'Map attributes to XML' do
        extend SpecHelper::XCScheme

        before do
          @sut = Xcodeproj::XCScheme::TestAction::TestableReference.new(nil)
        end

        attributes = {
          :skipped => 'skipped',
          :parallelizable => 'parallelizable',
          :use_test_selection_whitelist => 'useTestSelectionWhitelist',
        }
        specs_for_bool_attr(attributes)

        # Reimplemented because `testExecutionOrdering` doesn't use standard YES/NO
        describe 'randomized' do
          it '#randomized? detect a true value' do
            @sut.xml_element.attributes['testExecutionOrdering'] = 'random'
            @sut.should.be.randomized?
          end

          it '#randomized? detect a false value' do
            @sut.xml_element.attributes['testExecutionOrdering'] = nil
            @sut.should.not.be.randomized?
          end
        end

        describe 'test_execution_ordering' do
          it '#test_execution_ordering return actual value' do
            @sut.xml_element.attributes['testExecutionOrdering'] = 'value'
            @sut.test_execution_ordering.should == 'value'
          end

          it '#test_execution_ordering= set actual value' do
            @sut.test_execution_ordering = 'newValue'
            @sut.xml_element.attributes['testExecutionOrdering'].should == 'newValue'
          end
        end
      end

      it '#add_skipped_test' do
        test_ref = XCScheme::TestAction::TestableReference.new
        skipped_test = XCScheme::TestAction::TestableReference::Test.new
        skipped_test.identifier = 'MyClassTests'
        test_ref.add_skipped_test(skipped_test)
        test_ref.xml_element.elements['SkippedTests'].should.not.nil?
        test_ref.xml_element.elements['SkippedTests'].count.should == 1
        test_ref.xml_element.elements['SkippedTests'].elements['Test'].should == skipped_test.xml_element
      end

      it '#set_skipped_tests_nil' do
        test_ref = XCScheme::TestAction::TestableReference.new
        test_ref.skipped_tests = [XCScheme::TestAction::TestableReference::Test.new]
        test_ref.skipped_tests.count.should == 1
        test_ref.skipped_tests = nil
        test_ref.xml_element.elements['SkippedTests'].should.nil?
        test_ref.skipped_tests.count.should == 0
      end

      it '#set_skipped_tests' do
        test_ref = XCScheme::TestAction::TestableReference.new

        test1 = XCScheme::TestAction::TestableReference::Test.new
        test1.identifier = 'MyClassTests1'

        test2 = XCScheme::TestAction::TestableReference::Test.new
        test2.identifier = 'MyClassTests2'

        test_ref.skipped_tests = [test1, test2]
        test_ref.skipped_tests.count.should == 2
        test_ref.skipped_tests.all? { |e| e.class.should == XCScheme::TestAction::TestableReference::Test }
        test_ref.skipped_tests[0].xml_element.should == test1.xml_element
        test_ref.skipped_tests[1].xml_element.should == test2.xml_element
      end

      it '#skipped_tests' do
        test_ref = XCScheme::TestAction::TestableReference.new

        test1 = XCScheme::TestAction::TestableReference::Test.new
        test1.identifier = 'MyClassTests1'
        test_ref.add_skipped_test(test1)

        test2 = XCScheme::TestAction::TestableReference::Test.new
        test2.identifier = 'MyClassTests2'
        test_ref.add_skipped_test(test2)

        test_ref.skipped_tests.count.should == 2
        test_ref.skipped_tests.all? { |e| e.class.should == XCScheme::TestAction::TestableReference::Test }
        test_ref.skipped_tests[0].xml_element.should == test1.xml_element
        test_ref.skipped_tests[1].xml_element.should == test2.xml_element
      end

      it '#add_selected_test' do
        test_ref = XCScheme::TestAction::TestableReference.new
        selected_test = XCScheme::TestAction::TestableReference::Test.new
        selected_test.identifier = 'MyClassTests'
        test_ref.add_selected_test(selected_test)
        test_ref.xml_element.elements['SelectedTests'].should.not.nil?
        test_ref.xml_element.elements['SelectedTests'].count.should == 1
        test_ref.xml_element.elements['SelectedTests'].elements['Test'].should == selected_test.xml_element
      end

      it '#set_selected_tests_nil' do
        test_ref = XCScheme::TestAction::TestableReference.new
        test_ref.selected_tests = [XCScheme::TestAction::TestableReference::Test.new]
        test_ref.selected_tests.count.should == 1
        test_ref.selected_tests = nil
        test_ref.xml_element.elements['SelectedTests'].should.nil?
        test_ref.selected_tests.count.should == 0
      end

      it '#set_selected_tests' do
        test_ref = XCScheme::TestAction::TestableReference.new

        test1 = XCScheme::TestAction::TestableReference::Test.new
        test1.identifier = 'MyClassTests1'

        test2 = XCScheme::TestAction::TestableReference::Test.new
        test2.identifier = 'MyClassTests2'

        test_ref.selected_tests = [test1, test2]
        test_ref.selected_tests.count.should == 2
        test_ref.selected_tests.all? { |e| e.class.should == XCScheme::TestAction::TestableReference::Test }
        test_ref.selected_tests[0].xml_element.should == test1.xml_element
        test_ref.selected_tests[1].xml_element.should == test2.xml_element
      end

      it '#selected_tests' do
        test_ref = XCScheme::TestAction::TestableReference.new

        test1 = XCScheme::TestAction::TestableReference::Test.new
        test1.identifier = 'MyClassTests1'
        test_ref.add_selected_test(test1)

        test2 = XCScheme::TestAction::TestableReference::Test.new
        test2.identifier = 'MyClassTests2'
        test_ref.add_selected_test(test2)

        test_ref.selected_tests.count.should == 2
        test_ref.selected_tests.all? { |e| e.class.should == XCScheme::TestAction::TestableReference::Test }
        test_ref.selected_tests[0].xml_element.should == test1.xml_element
        test_ref.selected_tests[1].xml_element.should == test2.xml_element
      end

      it '#add_buildable_reference' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        test_ref = XCScheme::TestAction::TestableReference.new

        target = project.new_target(:application, 'FooApp', :ios)
        ref = XCScheme::BuildableReference.new(target)
        test_ref.add_buildable_reference(ref)

        test_ref.xml_element.elements['BuildableReference'].should == ref.xml_element
      end

      it '#remove_buildable_reference' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        test_ref = XCScheme::TestAction::TestableReference.new

        target = project.new_target(:application, 'FooApp', :ios)
        ref = XCScheme::BuildableReference.new(target)
        test_ref.add_buildable_reference(ref)

        test_ref.xml_element.elements['BuildableReference'].should == ref.xml_element
        test_ref.remove_buildable_reference(ref)
        test_ref.xml_element.elements['BuildableReference'].should.nil?
      end

      it '#buildable_references' do
        project = Xcodeproj::Project.new('/foo/bar/baz.xcodeproj')
        test_ref = XCScheme::TestAction::TestableReference.new

        target1 = project.new_target(:application, 'FooApp', :ios)
        ref1 = XCScheme::BuildableReference.new(target1)
        test_ref.add_buildable_reference(ref1)

        target2 = project.new_target(:static_library, 'FooLib', :ios)
        ref2 = XCScheme::BuildableReference.new(target2)
        test_ref.add_buildable_reference(ref2)

        test_ref.buildable_references.count.should == 2
        test_ref.buildable_references.all? { |e| e.class.should == XCScheme::BuildableReference }
        test_ref.buildable_references[0].xml_element.should == ref1.xml_element
        test_ref.buildable_references[1].xml_element.should == ref2.xml_element
      end
    end
  end
end
