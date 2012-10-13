require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs

  describe Hash do

    it "returns the recursive diff with another hash" do
      h1 = { :common => 'value', :changed => 'v1' }
      h2 = { :common => 'value', :changed => 'v2', :addition => 'new_value' }

      h1.recursive_diff(h2).should == {
        :changed => {
          :self  => 'v1',
          :other => 'v2'
        },
        :addition => {
          :self  => nil,
          :other => 'new_value'
        }
      }
    end

  end
end
