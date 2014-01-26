require File.expand_path('../../spec_helper', __FILE__)
require 'xcodeproj/config/parser'

class Xcodeproj::Config
  describe Parser do
    it "generates a BuildSetting for a setting and value assignment" do
      config = Parser.parse('OTHER_LDFLAGS = -framework Foundation')
      setting = config.settings.first
      setting.should.be.instance_of BuildSetting
      setting.name.to_s.should == 'OTHER_LDFLAGS'
      setting.value.to_s.should == '-framework Foundation'
    end

    it "stores the file location info for each setting field" do
      path = Pathname.new('some/custom.xcconfig')
      config = Parser.parse('OTHER_LDFLAGS = -framework Foundation', path)
      setting = config.settings.first
      setting.name.defined_at.container.should == path
      setting.name.defined_at.line_number.should == 1
      setting.name.defined_at.character_number.should == 1
      setting.value.defined_at.container.should == path
      setting.value.defined_at.line_number.should == 1
      setting.value.defined_at.character_number.should == 17
    end
  end
end
