module Xcodeproj
  class Command
    class TargetDiff < Command
      self.summary = 'Show diff of two targets in a project'
      self.description = 'Shows the difference between two targets. (Only build source files atm.)'
      self.arguments = 'TARGET_1 TARGET_2 [PATH]'

      def initialize(argv)
        @target1 = argv.shift_argument
        @target2 = argv.shift_argument
        super
      end

      def validate!
        super
        unless @target1
          help! "A target to compare FROM is required."
        end
        unless @target2
          help! "A target to compare TO is required."
        end
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

