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
