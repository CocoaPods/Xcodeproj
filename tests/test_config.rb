require "rubygems"
require "test/unit"
require "xcodeproj"
require "config_tests_helper"

class TestXcodeprojConfig < Test::Unit::TestCase
  def setup
    @config_data = { 'Key1' => 'Value1', 'Key2' => 'Value2' }
    @new_key_to_merge = 'Key3'
    @existing_key_to_merge = 'Key2'
    @value_to_merge = 'Value3'
    @config_data_to_merge = { @key_to_merge => @value_to_merge }
    @config = Xcodeproj::Config.new(@config_data)
  end

  def test_creation_with_hash
    key = 'Key'
    value = 'Value'
    config = Xcodeproj::Config.new( { key => value } )
    assert_not_nil(config)
    validate_xcconfig_contains_key_value(config, key, value)
  end

  def test_creation_with_path
    config = Xcodeproj::Config.new(relative_path_for_asset('oneline-key-value.xcconfig'))
    assert_not_nil(config);
    validate_xcconfig_contains_key_value(config, 'Key', 'Value')
  end

  def test_creation_with_file
    xcconfig_file = File.new(relative_path_for_asset('oneline-key-value.xcconfig'))
    config = Xcodeproj::Config.new(xcconfig_file)
    assert_not_nil(config);
    validate_xcconfig_contains_key_value(config, 'Key', 'Value')
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

  def test_includes_from_file
    config = Xcodeproj::Config.new(relative_path_for_asset('include.xcconfig'))
    assert_equal(1, config.includes.size)
    assert_equal('Somefile', config.includes.first)
  end

end