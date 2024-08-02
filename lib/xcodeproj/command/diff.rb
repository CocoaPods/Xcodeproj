module Xcodeproj
  class DiffCommand < Command
    require 'xcodeproj/command/diff/project'
    require 'xcodeproj/command/diff/target'

    self.abstract_command = true
    self.command = 'diff'
    self.description = 'Shows the differences between Xcode objects.'
  end
end
