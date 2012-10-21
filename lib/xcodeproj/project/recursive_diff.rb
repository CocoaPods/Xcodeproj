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
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    if other.is_a?(Hash)
      r = {}
      all_keys = self.keys + other.keys
      all_keys.each do |key|
        v1 = self[key]
        v2 = other[key]
        diff = v1.recursive_diff(v2, self_key, other_key)
        r[key] = diff if diff
      end
      r unless r == {}
    else
      super
    end
  end

  # @return [void]
  #
  def recursive_delete(key_to_delete)
    delete(key_to_delete)
    self.each do |key, value|
      case value
      when Hash
        value.recursive_delete(key_to_delete)
      when Array
        value.each { |v| v.recursive_delete(key_to_delete) if v.is_a?(Hash)}
      end
    end
  end
end


class Array

  # @return [Array]
  #
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    if other.is_a?(Array)
      new_objects_self  = (self - other)
      new_objects_other = (other - self)
      unmatched_objects_self = []
      array_result = []

      # Try to match objects to reduce noise
      new_objects_self.each do |value|
        if value.is_a?(Hash)
          other_value = new_objects_other.find do |other|
            other.is_a?(Hash) && (value['displayName'] == other['displayName'])
          end

          if other_value
            new_objects_other.delete(other_value)
            match_diff = value.recursive_diff(other_value, self_key, other_key)
            array_result << { value['displayName'] => match_diff} unless match_diff == {}
          else
            unmatched_objects_self << value
          end
        end
      end

      unless unmatched_objects_self.empty?
        array_result << {
          self_key => unmatched_objects_self.map do |v|
            { v['displayName'] => v }
          end
        }
      end

      unless new_objects_other.empty?
        array_result << {
          other_key => new_objects_other.map do |v|
            { v['displayName'] => v }
          end
        }
      end

      array_result unless array_result == []
    else
      super
    end
  end
end

class Object

  # @return [Hash]
  #
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    { self_key => self, other_key => other } unless self == other
  end
end
