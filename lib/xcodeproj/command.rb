require 'colored'
require 'claide'

module Xcodeproj
  class PlainInformative
    include CLAide::InformativeError
  end

  class Command < CLAide::Command
    self.abstract_command = true
    self.description = 'Manage Xcode projects.'

    def self.banner
      commands = ['target-diff', 'project-diff', 'show']
      banner   = "To see help for the available commands run:\n\n"
      banner + commands.map { |cmd| "  * $ xcodeproj #{cmd.green} --help" }.join("\n")
    end

    def self.options
      [['--version',  'Prints the version of CocoaPods']].concat(super)
    end

    def self.run(argv)
      argv = CLAide::ARGV.new(argv)
      if argv.flag?('version')
        puts VERSION
        exit!(0)
      end
      super(argv)
    end

    def initialize(argv)
      if path = argv.shift_argument
        @xcodeproj_path = File.expand_path(path)
      end
      super
    end

    def xcodeproj_path
      unless @xcodeproj_path
        projects = Dir.glob('*.xcodeproj')
        if projects.size == 1
          xcodeproj_path = projects.first
        elsif projects.size > 1
          help! 'There are more than one Xcode project documents ' \
                'in the current working directory. Please specify ' \
                'which to use with the `PATH` argument.'
        else
          help! 'No Xcode project document found in the current ' \
                'working directory. Please specify which to use ' \
                'with the `PATH` argument.'
        end
        @xcodeproj_path = File.expand_path(xcodeproj_path)
      end
      @xcodeproj_path
    end

    def xcodeproj
      @xcodeproj ||= Project.new(xcodeproj_path)
    end
  end
end

require 'xcodeproj/command/target_diff'
require 'xcodeproj/command/project_diff'
require 'xcodeproj/command/show'
