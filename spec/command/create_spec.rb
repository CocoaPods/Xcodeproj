require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  class Command
    class Create < Command
      self.arguments = [
        CLAide::Argument.new('PROJECT', true),
      ]

      def initialize(argv)
        self.xcodeproj_path = argv.shift_argument
        super
      end

      def validate!
        super
        help! "Project file not specified" if self.xcodeproj_path.nil?
      end
    end
  end
end


describe Xcodeproj::Command::Create do
  it 'errors if a project file has not been provided' do
    argv = CLAide::ARGV.new([])
    create = Xcodeproj::Command::Create.new(argv)
    should_raise_help 'Project file not specified' do
      create.validate!
    end
  end

  it 'errors if the specified project file already exists'

  it 'creates a project file'
end
