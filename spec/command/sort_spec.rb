require File.expand_path('../../spec_helper', __FILE__)

class MockXcodeproj
  def initialize(sort_assertion)
    @sort_assertion = sort_assertion
  end

  def sort(options)
    @sort_assertion.call(options)
  end

  def save
  end
end

describe Xcodeproj::Command::Sort do
  it 'Can accept above group-option.' do
    argv = CLAide::ARGV.new(['spec/fixtures/Sample Project/Cocoa Application.xcodeproj', '--group-option=above'])
    sort = Xcodeproj::Command::Sort.new(argv)
    sort.instance_variable_get(:@group_option).should == :above
    sort.validate!.should.not.be.nil
    sort.instance_variable_set(:@xcodeproj, MockXcodeproj.new(->(options) { options.should.be == { :groups_position => :above } }))
    sort.run
  end

  it 'Can accept below group-option.' do
    argv = CLAide::ARGV.new(['spec/fixtures/Sample Project/Cocoa Application.xcodeproj', '--group-option=below'])
    sort = Xcodeproj::Command::Sort.new(argv)
    sort.instance_variable_get(:@group_option).should == :below
    sort.validate!.should.not.be.nil
    sort.instance_variable_set(:@xcodeproj, MockXcodeproj.new(->(options) { options.should.be == { :groups_position => :below } }))
    sort.run
  end

  it 'Can accept missing group-option.' do
    argv = CLAide::ARGV.new(['spec/fixtures/Sample Project/Cocoa Application.xcodeproj'])
    sort = Xcodeproj::Command::Sort.new(argv)
    sort.instance_variable_get(:@group_option).should.be.nil
    sort.validate!.should.not.be.nil
    sort.instance_variable_set(:@xcodeproj, MockXcodeproj.new(->(options) { options.should.be == { :groups_position => nil } }))
    sort.run
  end

  it 'raise error when unknown group-option.' do
    argv = CLAide::ARGV.new(['spec/fixtures/Sample Project/Cocoa Application.xcodeproj', '--group-option=invalid'])
    sort = Xcodeproj::Command::Sort.new(argv)
    sort.instance_variable_get(:@group_option).should.be == :invalid
    should_raise_help 'Unknown format `invalid`' do
      sort.validate!
    end
  end
end
