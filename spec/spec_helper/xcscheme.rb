module SpecHelper
  module XCScheme
    def specs_for_bool_attr(attributes_map)
      attributes_map.each do |property, xml_attribute_name|
        attr_reader_sym = (property.to_s + '?').to_sym
        attr_writer_sym = (property.to_s + '=').to_sym

        describe property do
          it "##{property}? detect a true value" do
            @sut.xml_element.attributes[xml_attribute_name] = 'YES'
            @sut.send(attr_reader_sym).should == true
          end

          it "##{property}? detect a false value" do
            @sut.xml_element.attributes[xml_attribute_name] = 'NO'
            @sut.send(attr_reader_sym).should == false
          end

          it "##{property}? detect an invalid value" do
            @sut.xml_element.attributes[xml_attribute_name] = 'BadValue'
            should.raise(Xcodeproj::Informative) { @sut.send(attr_reader_sym) }
          end

          it "##{property}= set true value" do
            @sut.send(attr_writer_sym, true)
            @sut.xml_element.attributes[xml_attribute_name].should == 'YES'
          end

          it "##{property}= set false value" do
            @sut.send(attr_writer_sym, false)
            @sut.xml_element.attributes[xml_attribute_name].should == 'NO'
          end
        end
      end
    end

    def check_load_pre_and_post_actions_from_file(scheme_actions)
      scheme_actions.each do |scheme_action|
        it "load pre_actions from file for #{scheme_action}" do
          pre_action1 = @scheme.send(scheme_action).pre_actions[0]
          pre_action1.action_type.should == Xcodeproj::Constants::EXECUTION_ACTION_TYPE[:shell_script]
          pre_action1.action_content.title.should == 'Run Script'
          pre_action1.action_content.script_text.should == "echo foo\n"
          pre_action1.action_content.shell_to_invoke.should == '/bin/sh'

          pre_action1.action_content.buildable_reference.should.not.nil?
          ref_pre_action1 = pre_action1.action_content.buildable_reference
          ref_pre_action1.target_name.should == 'SharedSchemes'
          ref_pre_action1.target_uuid.should == '632143E8175736EE0038D40D'
          ref_pre_action1.buildable_name.should == 'SharedSchemes.app'
          ref_pre_action1.target_referenced_container.should == 'container:SharedSchemes.xcodeproj'

          pre_action2 = @scheme.send(scheme_action).pre_actions[1]
          pre_action2.action_type.should == Xcodeproj::Constants::EXECUTION_ACTION_TYPE[:send_email]
          pre_action2.action_content.title.should == 'Send Email'
          pre_action2.action_content.email_recipient.should == 'foo@foo.com'
          pre_action2.action_content.email_subject.should == 'Foo'
          pre_action2.action_content.email_body.should == 'Foo'
          pre_action2.action_content.attach_log_to_email?.should == false
        end

        it "load post_actions from file for #{scheme_action}" do
          post_action1 = @scheme.send(scheme_action).post_actions[0]
          post_action1.action_type.should == Xcodeproj::Constants::EXECUTION_ACTION_TYPE[:shell_script]
          post_action1.action_content.title.should == 'Run Script'
          post_action1.action_content.script_text.should == "echo foo\n"
          post_action1.action_content.shell_to_invoke.should == '/bin/sh'

          post_action1.action_content.buildable_reference.should.not.nil?
          ref_post_action1 = post_action1.action_content.buildable_reference
          ref_post_action1.target_name.should == 'SharedSchemes'
          ref_post_action1.target_uuid.should == '632143E8175736EE0038D40D'
          ref_post_action1.buildable_name.should == 'SharedSchemes.app'
          ref_post_action1.target_referenced_container.should == 'container:SharedSchemes.xcodeproj'

          post_action2 = @scheme.send(scheme_action).post_actions[1]
          post_action2.action_type.should == Xcodeproj::Constants::EXECUTION_ACTION_TYPE[:send_email]
          post_action2.action_content.title.should == 'Send Email'
          post_action2.action_content.email_recipient.should == 'foo@foo.com'
          post_action2.action_content.email_subject.should == 'Foo'
          post_action2.action_content.email_body.should == 'Foo'
          post_action2.action_content.attach_log_to_email?.should == false
        end
      end
    end
  end
end
