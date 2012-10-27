module Xcodeproj
  class Command
    class Show < Command
      self.summary = 'Show an overview of a project'
      self.description = 'Shows an overview of a project in a YAML representation.'
      self.arguments = '[PATH]'

      def run
        require 'yaml'
        yaml = xcodeproj.to_tree_hash.to_yaml
        puts yaml
      end
    end
  end
end


