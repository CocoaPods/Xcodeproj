module Xcodeproj
  class Command
    class ProjectDiff < Command
      def self.banner
%{Shows the difference between two projects:

    $ project-diff PROJECT_1 PROJECT_2

      It shows the difference in a UUID agnostic fashion.

      To reduce the noise (and to simplify implementation) differences in the
      order of arrays are ignored.}
      end

      def self.options
        [ ["--ignore KEY", "A key to ignore in the comparison. Can be specified multiple times."] ].concat(super)
      end

      def initialize(argv)
        @path_project1  = argv.shift_argument
        @path_project2  = argv.shift_argument
        unless @path_project1 && @path_project2
          raise Informative, "Two project paths are required."
        end
        @keys_to_ignore = []
        while (idx = argv.index('--ignore'))
          @keys_to_ignore << argv.delete_at(idx + 1)
          argv.delete_at(idx)
        end
        super unless argv.empty?
      end


      def run
        hash_1 = Project.new(@path_project1).to_tree_hash
        hash_2 = Project.new(@path_project2).to_tree_hash
        (@keys_to_ignore).each do |key|
          hash_1.recursive_delete(key)
          hash_2.recursive_delete(key)
        end

        diff = hash_1.recursive_diff(hash_2, @path_project1, @path_project2)
        diff.recursive_delete('displayName')

        require 'yaml'
        yaml = diff.to_yaml
        yaml = yaml.gsub(@path_project1, @path_project1.cyan)
        yaml = yaml.gsub(@path_project2, @path_project2.magenta)
        puts yaml
      end
    end
  end
end


