require File.expand_path('../spec_helper', __FILE__)

describe Xcodeproj::Constants do
  describe 'COMMON_BUILD_SETTINGS' do
    def subject
      Xcodeproj::Constants::COMMON_BUILD_SETTINGS
    end

    it 'has a key :all' do
      subject[:all].should.not.be.nil
    end

    it 'has keys which are arrays' do
      (subject.keys - [:all]).all? { |k| k.instance_of? Array }.should.be.true
    end

    it 'has values which are all frozen' do
      subject.select { |_, v| !v.frozen? }.keys.should.be.empty
    end
  end
end
