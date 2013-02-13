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
        pretty_print = xcodeproj.pretty_print
        sections = []
        pretty_print.each do |key, value|
        section = key.green
          yaml = value.to_yaml
          yaml.gsub!(/^---$/,'')
          yaml.gsub!(/^-/,"\n-")
          section << yaml
          sections << section
        end
        puts sections * "\n\n"
      end
    end
  end
end


