module Xcodeproj
  class Command
    class Sort < Command
      def self.banner
        %(Sorts the give project

            $ sort [PROJECT]

              If no `PROJECT' is specified then the current work directory is searched
              for one.)
      end

      def initialize(argv)
        xcodeproj_path = argv.shift_argument
        @xcodeproj_path = File.expand_path(xcodeproj_path) if xcodeproj_path
        super unless argv.empty?
      end

      def run
        xcodeproj.sort
        xcodeproj.save
        puts "The `#{File.basename(xcodeproj_path)}` project was sorted"
      end
    end
  end
end
