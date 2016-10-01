module Xcodeproj
  class Command
    class Sort < Command
      self.description = <<-eos
        Sorts the given project.

        If no `PROJECT' is specified then the current work directory is searched for one.
      eos

      self.summary = 'Sorts the given project.'

      self.arguments = [
        CLAide::Argument.new('PROJECT', false),
      ]

      def initialize(argv)
        self.xcodeproj_path = argv.shift_argument
        super
      end

      def validate!
        super
        open_project!
      end

      def run
        xcodeproj.sort
        xcodeproj.save
        puts "The `#{File.basename(xcodeproj_path)}` project was sorted"
      end
    end
  end
end
