require "rubygems"
require "test/unit"
require "xcodeproj"

class TestXcodeprojConfig < Test::Unit::TestCase
  def setup
    @config_data = { 'Key1' => 'Value1', 'Key2' => 'Value2' }
    @new_key_to_merge = 'Key3'
    @existing_key_to_merge = 'Key2'
    @value_to_merge = 'Value3'
    @config_data_to_merge = { @key_to_merge => @value_to_merge }
    @config = Xcodeproj::Config.new(@config_data)
  end

  def test_to_s
    config_as_string = @config.to_s
    assert_equal("Key1 = Value1\nKey2 = Value2", config_as_string)
  end

  def test_to_hash
    config_as_hash = @config.to_hash
    assert_equal(@config_data, config_as_hash)
  end

  def test_equality_of_two_xcconfigs
    config_dupe = Xcodeproj::Config.new(@config_data)
    assert_equal(config_dupe, @config)
  end

  def test_merge_with_xcconfig
    unique_config = Xcodeproj::Config.new(@config_data_to_merge)
    @config.merge!(unique_config)
    validate_xcconfig_contains_key_value(@config, @key_to_merge, @value_to_merge)
  end

  def test_merge_with_hash
    @config.merge!(@config_data_to_merge)
    validate_xcconfig_contains_key_value(@config, @key_to_merge, @value_to_merge)
  end

  def test_merge_with_existing_key
    existing_value = @config.to_hash[@existing_key_to_merge]
    @config << { @existing_key_to_merge => @value_to_merge }
    expected_new_value = "#{existing_value} #{@value_to_merge}"
    assert_equal(expected_new_value, @config.to_hash[@existing_key_to_merge])
  end

  def validate_xcconfig_contains_key_value(xcconfig, key, value)
    config_as_hash = xcconfig.to_hash
    assert_equal(true, config_as_hash.has_key?(key))
    assert_equal(value, config_as_hash[key])
  end
end