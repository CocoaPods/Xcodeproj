require File.expand_path('../../spec_helper', __FILE__)
require 'xcodeproj/config/lexer'

class Xcodeproj::Config

  shared "a lexer" do
    it "coerces input to a string" do
      should.raise TypeError do
        lex(BasicObject.new)
      end
      should.not.raise do
        o = BasicObject.new
        def o.to_str; ''; end
        lex(o)
      end
    end

    it "produces an empty list" do
      lex('').should == []
    end
  end

  describe 'Lexer.tokenize_config' do
    def lex(input)
      Lexer.lex_config(input)
    end

    behaves_like "a lexer"

    it "parses a config file inclusion" do
      lex(%{#include "project.xcconfig"}).should == [
        { :type => :include, :token => 'project.xcconfig', :line_number => 1, :character_number => 11 },
      ]
    end

    it "parses comments" do
      lex(%{//Some\n// comments\n //}).should == [
        { :type => :comment, :token => %{Some},     :line_number => 1, :character_number => 3 },
        { :type => :comment, :token => %{comments}, :line_number => 2, :character_number => 4 },
      ]
    end

    it "parses a value assignment" do
      lex(%{OTHER_LDFLAGS = -framework Foundation;}).should == [
        { :type => :setting, :token => 'OTHER_LDFLAGS',         :line_number => 1, :character_number => 1  },
        { :type => :value,   :token => '-framework Foundation', :line_number => 1, :character_number => 17 },
      ]
    end

    it "does not treat string quotes differently, they are included verbatim" do
      lex(%{SINGLE_QUOTE_STRING = 'some\\ncontent'\nDOUBLE_QUOTE_STRING = "some\\ncontent"}).should == [
        { :type => :setting, :token => 'SINGLE_QUOTE_STRING', :line_number => 1, :character_number => 1  },
        { :type => :value,   :token => %{'some\\ncontent'},   :line_number => 1, :character_number => 23 },
        { :type => :setting, :token => 'DOUBLE_QUOTE_STRING', :line_number => 2, :character_number => 1  },
        { :type => :value,   :token => %{"some\\ncontent"},   :line_number => 2, :character_number => 23 },
      ]
    end

    it "ignores a semicolon if it's the last non-whitespace character on a line" do
      lex(%{SEMI_COLON_TERMINATED = content; \nSEMI_COLON_TERMINATED_ONCE = content;;\t\nSEMI_COLON_INCLUDED = some; content}).should == [
        { :type => :setting, :token => 'SEMI_COLON_TERMINATED',      :line_number => 1, :character_number => 1  },
        { :type => :value,   :token => 'content',                    :line_number => 1, :character_number => 25 },
        { :type => :setting, :token => 'SEMI_COLON_TERMINATED_ONCE', :line_number => 2, :character_number => 1  },
        { :type => :value,   :token => 'content;',                   :line_number => 2, :character_number => 30 },
        { :type => :setting, :token => 'SEMI_COLON_INCLUDED',        :line_number => 3, :character_number => 1  },
        { :type => :value,   :token => 'some; content',              :line_number => 3, :character_number => 23 },
      ]
    end
  end

  describe 'Lexer.tokenize_value' do
    def lex(input)
      Lexer.lex_value(input)
    end

    behaves_like "a lexer"

    it "parses a string" do
      lex('foo').should == [
        { :type => :string, :token => 'foo', :character_number => 1 },
      ]
    end

    it "parses whitespace" do
      # TODO tabs?
      lex(' foo  ').should == [
        { :type => :space,  :token => ' ',   :character_number => 1 },
        { :type => :string, :token => 'foo', :character_number => 2 },
        { :type => :space,  :token => '  ',  :character_number => 5 },
      ]
    end

    it "parses interoplated variables" do
      # TODO are these the only types?
      lex('$(inherited) ${OTHER_LDFLAGS}').should == [
        { :type => :setting, :token => 'inherited',     :character_number => 3  },
        { :type => :space,   :token => ' ',             :character_number => 13 },
        { :type => :setting, :token => 'OTHER_LDFLAGS', :character_number => 16 },
      ]
    end
  end

end
