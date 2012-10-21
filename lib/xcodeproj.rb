module Xcodeproj
  VERSION = '0.4.0.rc1'

  class PlainInformative < StandardError
  end

  class Informative < PlainInformative
    def message
      super !~ /\[!\]/ ? "[!] #{super}\n".red : super
    end
  end

  autoload :Config,    'xcodeproj/config'
  autoload :Command,   'xcodeproj/command'
  autoload :Constants, 'xcodeproj/constants'
  autoload :Helper,    'xcodeproj/helper'
  autoload :Project,   'xcodeproj/project'
  autoload :Workspace, 'xcodeproj/workspace'
end
