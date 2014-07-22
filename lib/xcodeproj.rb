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
  autoload :PlistHelper,      'xcodeproj/plist_helper'
  autoload :Project,          'xcodeproj/project'
  autoload :Workspace,        'xcodeproj/workspace'
  autoload :XCScheme,         'xcodeproj/scheme'
  autoload :XcodebuildHelper, 'xcodeproj/xcodebuild_helper'


  # TODO: Delete me (compatibility with CocoaPods 0.33.1)
  def self.read_plist(path)
    PlistHelper.read(path)
  end

  def self.write_plist(hash, path)
    PlistHelper.write(hash, path)
  end
end
