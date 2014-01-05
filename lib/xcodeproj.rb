module Xcodeproj

  class PlainInformative < StandardError
  end

  class Informative < PlainInformative
    def message
      super !~ /\[!\]/ ? "[!] #{super}\n".red : super
    end
  end

  require 'xcodeproj/user_interface'

  autoload :Command,          'xcodeproj/command'
  autoload :Config,           'xcodeproj/config'
  autoload :Constants,        'xcodeproj/constants'
  autoload :Differ,           'xcodeproj/differ'
  autoload :Helper,           'xcodeproj/helper'
  autoload :Project,          'xcodeproj/project'
  autoload :Workspace,        'xcodeproj/workspace'
  autoload :XCScheme,         'xcodeproj/scheme'
  autoload :XcodebuildHelper, 'xcodeproj/xcodebuild_helper'
end

# TODO It appears that loading the C ext from xcodeproj/project while it's
# being autoloaded doesn't actually define the singleton methods. Ruby bug?
#
# This leads to `NoMethodError: undefined method write_plist for Xcodeproj:Module`
# working around it by always loading the ext ASAP.
require 'xcodeproj/ext'
