module Xcodeproj
  class Command
    class Create < Command
      self.arguments = [
        CLAide::Argument.new('PROJECT', true),
      ]

      EXTENSION = '.xcodeproj'

      def initialize(argv)
        @project_name = argv.shift_argument

        add_extension_if_missing

        super
      end

      def validate!
        super
        help! "Project file not specified" if @project_name.nil?
        help! "Project already exists" if File.exist?(@project_name)
      end

      def run
        project = Xcodeproj::Project.new(@project_name)
        project.save
      end

      def add_extension_if_missing
        return unless @project_name

        @project_name += EXTENSION unless File.extname(@project_name) == EXTENSION
      end
    end
  end
end
