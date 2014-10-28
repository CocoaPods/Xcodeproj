module Xcodeproj
  class Project
    module XCProjHelper
      class << self
        # @return [Bool] Whether the xcproj tool is available.
        #
        def available?
          `which xcproj`
          $?.exitstatus.zero?
        end

        # Touches the project at the given path if the xcproj tool is
        # available.
        #
        # @return [void]
        #
        def touch(path)
          if available?
            command = "xcproj --project \"#{path}\" touch"
            success, output = execute(command)
            unless success
              message = 'The `xcproj` tool has failed to touch the project. ' \
                        'Check whether your installation of `xcproj` is ' \
                        "functional.\n\n"
              message << command << "\n"
              message << output
              UI.warn(message)
            end
          end
        end

        private

        # @!group Private Helpers
        #---------------------------------------------------------------------#

        # Executes the given command redirecting the standard error to the
        # standard output.
        #
        # @return [Array<Bool, String>] A tuple where the firs element
        # indicates whether the exit status of the command was 0 and the
        # second the output printed by the command.
        #
        def execute(command)
          output = `#{command} 2>&1`
          success = $?.exitstatus.zero?
          [success, output]
        end

        #---------------------------------------------------------------------#
      end
    end
  end
end
