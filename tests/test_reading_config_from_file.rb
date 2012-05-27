require "rubygems"
require "test/unit"
require "xcodeproj"
require "config_tests_helper"

class TestXcodeprojConfigParsingFromFiles < Test::Unit::TestCase
  
  def test_creation_from_multiline_key_value_file
    config = Xcodeproj::Config.new(relative_path_for_asset('multiline-key-value.xcconfig'))
    { 'Key1' => 'Value1', 'Key2' => 'Value2', 'Key3' => 'Value3' }.each do |key, value|
      validate_xcconfig_contains_key_value(config, key, value)
    end
  end
  
  def test_creation_from_oneline_key_values_file
    config = Xcodeproj::Config.new(relative_path_for_asset('oneline-key-values.xcconfig'))
    assert_not_nil(config);
    validate_xcconfig_contains_key_value(config, 'Key1', 'Value1 Value2')    
  end
  
  def test_creation_from_multiline_key_values_file
    config = Xcodeproj::Config.new(relative_path_for_asset('multiline-key-values.xcconfig'))
    { 'Key1' => 'Value1 Value2', 'Key2' => 'Value3 Value4 Value5', 'Key3' => 'Value6' }.each do |key, value|
      validate_xcconfig_contains_key_value(config, key, value)
    end    
  end
  
  def test_creation_from_oneline_key_value_with_comment_file
    config = Xcodeproj::Config.new(relative_path_for_asset('oneline-key-value-with-comment.xcconfig'))
    assert_not_nil(config);
    validate_xcconfig_contains_key_value(config, 'Key', 'Value')
  end
  
  def test_creation_from_file_with_empty_lines
    config = Xcodeproj::Config.new(relative_path_for_asset('empty-lines.xcconfig'))
    { 'Key1' => 'Value1', 'Key2' => 'Value2' }.each do |key, value|
      validate_xcconfig_contains_key_value(config, key, value)
    end
  end
  
  def test_creation_from_file_with_comment_starting_line
    config = Xcodeproj::Config.new(relative_path_for_asset('comment-starts-line.xcconfig'))
    assert_not_nil(config);
    validate_xcconfig_contains_key_value(config, 'Key', 'Value')
  end
  
  def test_creation_from_file_with_key_without_value
    config = Xcodeproj::Config.new(relative_path_for_asset('key-with-no-value.xcconfig'))
    assert_not_nil(config);
    validate_xcconfig_contains_key_value(config, 'Key', '')
  end
  
end