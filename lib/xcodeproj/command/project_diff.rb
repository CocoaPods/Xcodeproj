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
        [['--ignore KEY', 'A key to ignore in the comparison. Can be specified multiple times.']].concat(super)
      end

      def initialize(argv)
        @path_project1  = argv.shift_argument
        @path_project2  = argv.shift_argument
        unless @path_project1 && @path_project2
          raise Informative, 'Two project paths are required.'
        end
        @keys_to_ignore = []
        while (idx = argv.index('--ignore'))
          @keys_to_ignore << argv.delete_at(idx + 1)
          argv.delete_at(idx)
        end
        super unless argv.empty?
      end

      def run
        hash_1 = Project.new(@path_project1).to_tree_hash.dup
        hash_2 = Project.new(@path_project2).to_tree_hash.dup
        @keys_to_ignore.each do |key|
          Differ.clean_hash!(hash_1, key)
          Differ.clean_hash!(hash_2, key)
        end

        diff = Differ.project_diff(hash_1, hash_2, @path_project1, @path_project2)

        require 'yaml'
        yaml = diff.to_yaml
        yaml = yaml.gsub(@path_project1, @path_project1.cyan)
        yaml = yaml.gsub(@path_project2, @path_project2.magenta)
        yaml = yaml.gsub(':diff:', 'diff:'.yellow)
        puts yaml
      end
    end
  end
end
