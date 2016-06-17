require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../xcscheme_spec_helper', __FILE__)

module Xcodeproj
  @xml_formatter = REXML::Formatters::Pretty.new(0)
  @xml_formatter.compact = true

  def self.xml_for_object(object)
    xml_out = ''
    @xml_formatter.write(object.xml_element, xml_out)
    xml_out.lines.each(&:strip!).join('')
  end

  describe XCScheme::EnvironmentVariables do

    describe '#initialize' do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
      end

      describe 'creates a new EnvironmentVariable object' do
        it 'when passed nothing' do
          subject = XCScheme::EnvironmentVariables.new(@sut.scheme)
          Xcodeproj.xml_for_object(subject).should == '<EnvironmentVariables/>'
        end

        it 'when passed an array of hashes with key and value' do
          subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'key', :value => 'value' }])
          Xcodeproj.xml_for_object(subject).should ==
            "<EnvironmentVariables><EnvironmentVariable key='key' value='value' isEnabled='YES'/></EnvironmentVariables>"
        end

        it 'when passed an existing EnvironmentVariable XML node' do
          subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'key', :value => 'value' }])
          copy = XCScheme::EnvironmentVariables.new(@sut.scheme, subject.xml_element)
          subject.should.not.be.same_as copy
          Xcodeproj.xml_for_object(copy).should ==
            "<EnvironmentVariables><EnvironmentVariable key='key' value='value' isEnabled='YES'/></EnvironmentVariables>"
        end

        it 'when passed an array of XML nodes' do
          subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'key', :value => 'value' }])
          copy = XCScheme::EnvironmentVariables.new(@sut.scheme, subject.all_variables)
          Xcodeproj.xml_for_object(copy).should ==
            "<EnvironmentVariables><EnvironmentVariable key='key' value='value' isEnabled='YES'/></EnvironmentVariables>"
        end
      end
    end

    describe '#all_variables' do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
      end

      it 'returns an empty array' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme)
        subject.all_variables.should == []
      end

      it 'returns all items, regardless of enabled state' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'key1', :value => 'value1' },
                                                                   { :key => 'key2', :value => 'value2', :enabled => false }])
        subject.all_variables.count.should == 2
        subject.all_variables.each { |var| var.should.is_a? XCScheme::EnvironmentVariable }
        subject.all_variables[0].to_h.should == { :key => 'key1', :value => 'value1', :enabled => true }
        subject.all_variables[1].to_h.should == { :key => 'key2', :value => 'value2', :enabled => false }
      end
    end

    describe '#upsert_variable' do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
      end

      it 'adds a new environment variable by Hash' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme)
        subject.assign_variable(:key => 'key1', :value => 'value1')

        subject.all_variables.count.should == 1
        subject.all_variables.first.to_h.should == { :key => 'key1', :value => 'value1', :enabled => true }
        Xcodeproj.xml_for_object(subject).should ==
          "<EnvironmentVariables><EnvironmentVariable key='key1' value='value1' isEnabled='YES'/></EnvironmentVariables>"
      end

      it 'adds a new variable by object using the same object' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme)
        new_var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key1', :value => 'value1')
        subject.assign_variable(new_var)

        subject.all_variables.count.should == 1
        subject.all_variables.first.to_h.should == { :key => 'key1', :value => 'value1', :enabled => true }
        subject.all_variables.first.should.equal?(new_var)
      end

      it 'adds a new variable by node using the same xml_element' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme)
        new_var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key1', :value => 'value1')
        subject.assign_variable(new_var.xml_element)

        subject.all_variables.count.should == 1
        subject.all_variables.first.to_h.should == { :key => 'key1', :value => 'value1', :enabled => true }
        subject.all_variables.first.xml_element.should.equal?(new_var.xml_element)
      end

      it 'merges in a new entry if a matching key does not exist' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [:key => 'key1', :value => 'value1'])
        subject.assign_variable(:key => 'key2', :value => 'value2')
        subject.to_a.should == [{ :key => 'key1', :value => 'value1', :enabled => true },
                                { :key => 'key2', :value => 'value2', :enabled => true }]
      end

      it 'updates an existing variable value if one already exists with that key' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [:key => 'key1', :value => 'value1'])
        subject.assign_variable(:key => 'key1', :value => 'value3')
        subject.to_a.should == [:key => 'key1', :value => 'value3', :enabled => true]
      end

      it 'updates an existing variable enabled state if one already exists with that key' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'key1', :value => 'value1' },
                                                                   { :key => 'key2', :value => 'value2', :enabled => false }])
        subject.assign_variable(:key => 'key1', :value => 'value1', :enabled => false)
        subject.assign_variable(:key => 'key2', :value => 'value2')

        subject.to_a.should == [{ :key => 'key1', :value => 'value1', :enabled => false },
                                { :key => 'key2', :value => 'value2', :enabled => true }]
      end
    end

    describe '#remove_variable' do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
      end

      it 'returns the new set of environment variables after removal' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [{ :key => 'key1', :value => 'value1' },
                                                                   { :key => 'key2', :value => 'value2' }])
        subject.remove_variable('key1').first.to_h.should == { :key => 'key2', :value => 'value2', :enabled => true }
        subject.to_a.should == [:key => 'key2', :value => 'value2', :enabled => true]
        Xcodeproj.xml_for_object(subject).should ==
          "<EnvironmentVariables><EnvironmentVariable key='key2' value='value2' isEnabled='YES'/></EnvironmentVariables>"
      end

      it 'removes an existing entry with same EnvironmentVariable object' do
        new_var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key1', :value => 'value1')
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [new_var])
        subject.remove_variable(new_var)
        subject.to_a.should == []
        Xcodeproj.xml_for_object(subject).should == '<EnvironmentVariables/>'
      end

      it 'removes an existing entry with matching String' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [:key => 'key1', :value => 'value1'])
        subject.remove_variable('key1')
        subject.to_a.should == []
      end

      it 'does nothing if the the EnvironmentVariable isn\'t in all' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [:key => 'key1', :value => 'value1'])
        new_var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key2', :value => 'value2')
        subject.remove_variable(new_var)
        subject.to_a.should == [:key => 'key1', :value => 'value1', :enabled => true]
      end

      it 'does nothing if the variable does not exist' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [:key => 'key1', :value => 'value1'])
        new_var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key2', :value => 'value2')
        subject.remove_variable(new_var)
        subject.to_a.should == [:key => 'key1', :value => 'value1', :enabled => true]
      end

      it 'does nothing if the enabled state does not match' do
        subject = XCScheme::EnvironmentVariables.new(@sut.scheme, [:key => 'key1', :value => 'value1'])
        new_var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key1', :value => 'value2')
        new_var2 = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key1', :value => 'value1', :enabled => true)
        subject.remove_variable(new_var)
        subject.remove_variable(new_var2)
        subject.to_a.should == [:key => 'key1', :value => 'value1', :enabled => true]
      end
    end

    describe '#[] and #[]=' do
      before do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
        element = REXML::Document.new('<EnvironmentVariables>' \
                                      "<EnvironmentVariable key='key1' value='value1' isEnabled='NO'/>" \
                                      '</EnvironmentVariables>').elements['EnvironmentVariables']
        @subject = XCScheme::EnvironmentVariables.new(@sut.scheme, element)
      end

      it 'updates an existing key if one exists, and automatically sets it to be enabled' do
        @subject['key1'].class.should == XCScheme::EnvironmentVariable
        @subject['key1'].to_h.should == { :key => 'key1', :value => 'value1', :enabled => false }

        @subject['key1'] = 'updated'
        @subject.all_variables.count.should == 1
        @subject['key1'].to_h.should == { :key => 'key1', :value => 'updated', :enabled => true }
        Xcodeproj.xml_for_object(@subject['key1']).should == "<EnvironmentVariable key='key1' value='updated' isEnabled='YES'/>"
      end

      it 'inserts a new key if a match does not already exists' do
        @subject['key2'].should.be.nil

        @subject['key2'] = 'inserted'
        @subject.all_variables.count.should == 2
        @subject['key2'].to_h.should == { :key => 'key2', :value => 'inserted', :enabled => true }
        Xcodeproj.xml_for_object(@subject['key2']).should == "<EnvironmentVariable key='key2' value='inserted' isEnabled='YES'/>"
      end
    end
  end

  describe XCScheme::EnvironmentVariable do

    describe '#initialize' do
      describe 'raises an initialization error nil' do
        before do
          node = REXML::Element.new('BuildAction')
          @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
        end

        init_exception = /Must pass a Hash with 'key' and 'value'!/

        it 'when passed nil' do
          lambda { XCScheme::EnvironmentVariable.new(@sut.scheme, nil) }.should.raise(RuntimeError).message
            .should.match(init_exception)
        end

        it 'when Hash is empty' do
          lambda { XCScheme::EnvironmentVariable.new(@sut.scheme, {}) }.should.raise(RuntimeError).message
            .should.match(init_exception)
        end

        it 'when Hash is missing key' do
          lambda { XCScheme::EnvironmentVariable.new(@sut.scheme, :value => 'value') }.should.raise(RuntimeError)
            .message.should.match(init_exception)
        end

        it 'when Hash is missing value' do
          lambda { XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key') }.should.raise(RuntimeError)
            .message.should.match(init_exception)
        end
      end

      describe 'creates a new EnvironmentVariable object' do
        before do
          node = REXML::Element.new('BuildAction')
          @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
        end

        it 'when passed an array of hashes with key and value' do
          subject = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key', :value => 'value')
          Xcodeproj.xml_for_object(subject).should == "<EnvironmentVariable key='key' value='value' isEnabled='YES'/>"
        end

        it 'when passed an array of hashes with key, value and enabled state' do
          subject = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key', :value => 'value', :enabled => false)
          Xcodeproj.xml_for_object(subject).should == "<EnvironmentVariable key='key' value='value' isEnabled='NO'/>"
        end

        it 'when passed an XML node' do
          var = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'copykey', :value => 'copyvalue')
          subject = XCScheme::EnvironmentVariable.new(@sut.scheme, var.xml_element)
          Xcodeproj.xml_for_object(subject).should == "<EnvironmentVariable key='copykey' value='copyvalue' isEnabled='YES'/>"
          Xcodeproj.xml_for_object(subject).should == Xcodeproj.xml_for_object(var)
          subject.should.not.equal?(var)
        end
      end

      describe 'EnvironmentVariable accessors return values from the XML' do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)
        subject = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key', :value => 'value', :enabled => false)
        subject.key.should == 'key'
        subject.value.should == 'value'
        subject.enabled.should == false
      end

      describe 'EnvironmentVariable modifiers mutate the XML' do
        node = REXML::Element.new('BuildAction')
        @sut = Xcodeproj::XCScheme::BuildAction.new(XCSchemeStub.new, node)

        subject = XCScheme::EnvironmentVariable.new(@sut.scheme, :key => 'key', :value => 'value')
        Xcodeproj.xml_for_object(subject).should == "<EnvironmentVariable key='key' value='value' isEnabled='YES'/>"
        before_modifiers = subject.xml_element

        subject.key = 'key2'
        subject.value = 'value2'
        subject.enabled = false
        Xcodeproj.xml_for_object(subject).should == "<EnvironmentVariable key='key2' value='value2' isEnabled='NO'/>"
        subject.should.equal?(before_modifiers)
      end
    end
  end
end
