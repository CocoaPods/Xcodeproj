module Xcodeproj

  # Manages the UI output so dependent gems can customize it.
  #
  module UserInterface

    class << self
      def puts(message)
        STDOUT.puts message
      end

      def warn(message)
        STDERR.puts message
      end

    end
  end

  UI = UserInterface

end

