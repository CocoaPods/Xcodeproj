require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  class Command
    class Create < Command
      self.arguments = [
        CLAide::Argument.new('PROJECT', true),
      ]

      def initialize(argv)
        @project_name = argv.shift_argument
        super
      end

      def validate!
        super
        help! "Project file not specified" if @project_name.nil?
        help! "Project already exists" if File.exist?(@project_name)
      end

      def run
        project = Xcodeproj::Project.new(@project_name)
        project.save
      end
    end
  end
end

require 'fileutils'

describe Xcodeproj::Command::Create do
  it 'errors if a project file has not been provided' do
    argv = CLAide::ARGV.new([])
    create = Xcodeproj::Command::Create.new(argv)
    should_raise_help 'Project file not specified' do
      create.validate!
    end
  end

  it 'errors if the specified project already exists' do
    project_dir = 'FooBar.xcodeproj'
    FileUtils.mkdir(project_dir)

    argv = CLAide::ARGV.new([project_dir])
    create = Xcodeproj::Command::Create.new(argv)
    should_raise_help 'Project already exists' do
      create.validate!
    end

    FileUtils.rm_r(project_dir)
  end

  it 'creates a project file' do
    project_dir = 'FooBar.xcodeproj'
    argv = CLAide::ARGV.new([project_dir])
    create = Xcodeproj::Command::Create.new(argv)
    create.run

    File.exist?(project_dir).should.be.true

    FileUtils.rm_r(project_dir)
  end
end
