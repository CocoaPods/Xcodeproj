require "rubygems"
require "test/unit"
require "xcodeproj"

class TestXcodeprojConfig < Test::Unit::TestCase
  def test_creation
    config = Xcodeproj::Config.new
    assert_not_nil(config)
  end
end