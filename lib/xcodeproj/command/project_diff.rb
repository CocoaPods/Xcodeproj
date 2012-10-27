module Xcodeproj
  class Command
    class ProjectDiff < Command
      self.summary = 'Show diff of two projects'

      self.description = <<-DESC
        Shows the difference between two projects in an UUID agnostic fashion.

        To reduce the noise (and to simplify implementation) differences in the
        other of arrays are ignored.
      DESC

      self.arguments = 'PROJECT_1 PROJECT_2'

      def self.options
        [ ["--ignore=KEY,KEY,...", "Key(s) to ignore in the comparison."] ].concat(super)
      end

      def initialize(argv)
        @path_project1  = argv.shift_argument
        @path_project2  = argv.shift_argument
        @keys_to_ignore = []
        if ignore = argv.option('ignore')
          @keys_to_ignore = ignore.split(',')
        end
        super
      end

      def validate!
        super
        unless @path_project1
          help! "A path to a project to compare FROM is required."
        end
        unless @path_project2
          help! "A path to a project to compare TO is required."
        end
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


