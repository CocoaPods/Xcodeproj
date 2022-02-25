require File.expand_path('../../spec_helper', __FILE__)

module Xcodeproj
  class Command
    class Create < Command
      self.arguments = [
        CLAide::Argument.new('PROJECT', true),
      ]

      EXTENSION = '.xcodeproj'

      def initialize(argv)
        @project_name = argv.shift_argument

        add_extension_if_missing

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

      def add_extension_if_missing
        return unless @project_name

        @project_name += EXTENSION unless File.extname(@project_name) == EXTENSION
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
  ensure
    FileUtils.rm_r(project_dir)
  end

  it 'creates a project file' do
    project_dir = 'FooBar.xcodeproj'
    argv = CLAide::ARGV.new([project_dir])
    create = Xcodeproj::Command::Create.new(argv)
    create.run

    File.exist?(project_dir).should.be.true
  ensure
    FileUtils.rm_r(project_dir)
  end

  it 'adds the suffix if one is not provided' do
    project_name = 'FooBar'
    project_dir = 'FooBar.xcodeproj'
    argv = CLAide::ARGV.new([project_name])
    create = Xcodeproj::Command::Create.new(argv)
    create.run

    File.exist?(project_dir).should.be.true
  ensure
    FileUtils.rm_r(project_dir)
  end
end
