class Hash

  # Computes the recursive difference of two hashes.
  #
  # Useful to compare two projects.
  #
  # Inspired from 'active_support/core_ext/hash/diff'.
  #
  # @example
  #   h1 = { :common => 'value', :changed => 'v1' }
  #   h2 = { :common => 'value', :changed => 'v2', :addition => 'new_value' }

  #   h1.recursive_diff(h2) == {
  #     :changed => {
  #       :self  => 'v1',
  #       :other => 'v2'
  #     },
  #     :addition => {
  #       :self  => nil,
  #       :other => 'new_value'
  #     }
  #   } #=> true
  #
  # @return [Hash] Returns the recursive difference of a hash.
  #
  def recursive_diff(h2)
    r = {}
    all_keys = keys + h2.keys
    all_keys.each do |key|
      v1 = self[key]
      v2 = h2[key]

      if v1.is_a?(Hash) && v2.is_a?(Hash)
        diff = v1.recursive_diff(v2)
        r[key] = diff unless diff == {}
      elsif v1.is_a?(Array) && v2.is_a?(Array)
        # take into account only the members of the array that actually changed
        different_onbjects = (v1 - v2) + (v2 - v1)
        v1_hash = {}
        v1.each_with_index { |value, index| v1_hash[index] = value if different_onbjects.include?(value) }
        v2_hash = {}
        v2.each_with_index { |value, index| v2_hash[index] = value if different_onbjects.include?(value) }
        diff = v1_hash.recursive_diff(v2_hash)
        r[key] = diff unless diff == {}
      else
        # The key might be present only in one hash with nil value
        if v1 != v2
          r[key] = { :self => v1, :other => v2 }
        elsif !self.has_key?(key)
          r[key] = { :other => v2 }
        elsif !h2.has_key?(key)
          r[key] = { :self => v1 }
        end
      end
    end
    r
  end
end
