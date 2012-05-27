def validate_xcconfig_contains_key_value(xcconfig, key, value)
  config_as_hash = xcconfig.to_hash
  assert_equal(true, config_as_hash.has_key?(key))
  assert_equal(value, config_as_hash[key])
end

def relative_path_for_asset(asset)
  "tests/assets/#{asset}"
end