module Xcodeproj
  class Command
    class Show < Command
      def self.banner
        %(Shows an overview of a project in a YAML representation.'

            $ show [PROJECT]

              If no `PROJECT' is specified then the current work directory is searched
              for one.)
      end

      def self.options
        [
          ['--format [hash|tree_hash|raw]', 'YAML output format, optional'],
        ].concat(super)
      end

      def initialize(argv)
        xcodeproj_path = argv.shift_argument
        @xcodeproj_path = File.expand_path(xcodeproj_path) if xcodeproj_path

        if argv.option('--format')
          @output_format = argv.shift_argument
        end

        super unless argv.empty?
      end

      def run
        require 'yaml'

        if @output_format
          case @output_format.to_sym
          when :hash
            puts xcodeproj.to_hash.to_yaml
          when :tree_hash
            puts xcodeproj.to_tree_hash.to_yaml
          when :raw
            puts xcodeproj.to_yaml
          else
            raise Informative, "Unknowh format #{@output_format}!"
          end
          return
        end

        pretty_print = xcodeproj.pretty_print
        sections = []
        pretty_print.each do |key, value|
          section = key.green
          yaml = value.to_yaml
          yaml.gsub!(/^---$/, '')
          yaml.gsub!(/^-/, "\n-")
          section << yaml
          sections << section
        end
        puts sections * "\n\n"
      end
    end
  end
end
