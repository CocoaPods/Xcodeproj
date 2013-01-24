module Xcodeproj
  class Command
    class Show < Command
      def self.banner
%{Shows an overview of a project in a YAML representation.'

    $ show [PROJECT]

      If no `PROJECT' is specified then the current work directory is searched
      for one.}
      end

      def initialize(argv)
        xcodeproj_path = argv.shift_argument
        @xcodeproj_path = File.expand_path(xcodeproj_path) if xcodeproj_path
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


