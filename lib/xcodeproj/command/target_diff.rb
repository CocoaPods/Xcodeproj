module Xcodeproj
  class Command
    class TargetDiff < Command
      def self.banner
%{Shows the difference between two targets:

    $ targets-diff [target 1] [target 2]

      Only supports build source files atm.}
      end

      def self.options
        [
          ["--project PATH", "The Xcode project document to use."],
        ].concat(super)
      end

      def initialize(argv)
        @target1 = argv.shift_argument
        @target2 = argv.shift_argument
        if argv.option('--project')
          @xcodeproj_path = File.expand_path(argv.shift_argument)
        end
        super unless argv.empty?
      end

      def run
        require 'yaml'
        differ = Helper::TargetDiff.new(xcodeproj, @target1, @target2)
        files = differ.new_source_build_files.map do |build_file|
          {
            'Name' => build_file.file_ref.name,
            'Path' => build_file.file_ref.path,
            'Build settings' => build_file.settings,
          }
        end
        puts files.to_yaml
      end
    end
  end
end

