module Xcodeproj
  class Command
    class Show < Command
      def self.banner
%{Installing dependencies of a project:

    $ project-diff PROJECT_1 PROJECT_2

      Shows a YAML reppresentation of a project.
}
      end

      def self.options
        [
          ["--project PATH", "The Xcode project document to use."],
        ].concat(super)
      end

      def initialize(argv)
        if argv.option('--project')
          @xcodeproj_path = File.expand_path(argv.shift_argument)
        end
        super unless argv.empty?
      end

      def run
        require 'yaml'
        yaml = xcodeproj.to_tree_hash.to_yaml
        puts yaml
      end
    end
  end
end


