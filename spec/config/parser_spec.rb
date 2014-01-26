require File.expand_path('../../spec_helper', __FILE__)
require 'xcodeproj/config/parser'

class Xcodeproj::Config
  #describe Config do
    #before do
      #@top_level    = Config.new('TOP_LEVEL' => '1')
      #@middle_level = Config.new('MIDDLE_LEVEL', '2')
      #@bottom_level = Config.new('BOTTOM_LEVEL' => '3')

      #@bottom_level.parent = @middle_level
      #@middle_level.parent = @top_level
    #end

    #it "merges build settings from its parent" do
      #@top_level.to_hash.should == { 'TOP_LEVEL' => '1' }
      #@middle_level.to_hash.should == { 'TOP_LEVEL' => '1', 'MIDDLE_LEVEL' => '2' }
      #@bottom_level.to_hash.should == { 'TOP_LEVEL' => '1', 'MIDDLE_LEVEL' => '2', 'BOTTOM_LEVEL' => '3' }
    #end

    #it "finds where a build setting is defined" do
      #@top_level.defined_at('MIDDLE_LEVEL').should == []
      #@middle_level.defined_at('MIDDLE_LEVEL').should == [@middle_level]
      #@bottom_level.defined_at('MIDDLE_LEVEL').should == [@middle_level]

      #@bottom_level['TOP_LEVEL'] = '4'
      #@bottom_level.defined_at('TOP_LEVEL').should == [@bottom_level, @top_level]
      #@middle_level.defined_at('TOP_LEVEL').should == [@top_level]
      #@top_level.defined_at('TOP_LEVEL').should == [@top_level]
    #end
  #end

  describe Parser do
    it "generates a BuildSetting for a setting and value assignment" do
      config = Parser.parse_config('OTHER_LDFLAGS = $(inherited) -framework Foundation')
      setting = config.settings.first
      setting.name.content.should == 'OTHER_LDFLAGS'
    end

    it "automatically parses setting values" do
      config = Parser.parse_config('OTHER_LDFLAGS = $(inherited) -framework Foundation')
      fields = config.settings.first.value
      fields.map { |field| [field.type, field.content] }.should == [
        [:setting, 'inherited'],
        [:string, '-framework'],
        [:string, 'Foundation']
      ]
    end

    it "ignores comments" do
      config = Parser.parse_config(%{// comment 1\n//comment 2})
      config.settings.should.be.empty
    end

    it "stores the file location info for each field" do
      path = Pathname.new('some/custom.xcconfig')
      config = Parser.parse_config(%{// comment\nOTHER_LDFLAGS = $(inherited) -framework Foundation}, path)
      setting = config.settings.first

      setting.name.defined_at.container.should == path
      setting.name.defined_at.line_number.should == 2
      setting.name.defined_at.character_number.should == 1

      setting.value[0].defined_at.container.should == path
      setting.value[0].defined_at.line_number.should == 2
      setting.value[0].defined_at.character_number.should == 19

      setting.value[1].defined_at.container.should == path
      setting.value[1].defined_at.line_number.should == 2
      setting.value[1].defined_at.character_number.should == 30

      setting.value[2].defined_at.container.should == path
      setting.value[2].defined_at.line_number.should == 2
      setting.value[2].defined_at.character_number.should == 41
    end

    it "includes settings from another file relative to the current one" do
      path = Pathname.new('/some/custom.xcconfig')
      other_path = Pathname.new('/some/other.xcconfig')

      File.expects(:read).with(other_path.to_s).returns(%{//comment\nOTHER_LDFLAGS = $(inherited)})

      config = Parser.parse_config(%{#include "other.xcconfig"}, path)
      setting = config.settings.first
      setting.name.content.should == 'OTHER_LDFLAGS'
      setting.name.defined_at.container.should == other_path
      setting.name.defined_at.line_number.should == 2
      setting.name.defined_at.character_number.should == 1
      setting.value[0].content.should == 'inherited'
      setting.value[0].defined_at.container.should == other_path
      setting.value[0].defined_at.line_number.should == 2
      setting.value[0].defined_at.character_number.should == 19
    end
  end
end
