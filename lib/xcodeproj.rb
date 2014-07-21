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

  def self.generate_uuid
    require 'SecureRandom'
    SecureRandom.hex(12).upcase
  end

  def self.write_plist(hash, path)
    unless hash.is_a?(Hash)
      if hash.respond_to?(:to_hash)
        hash = hash.to_hash
      else
        raise TypeError, "The given #{hash}, must be a hash or respond to to_hash"
      end
    end
    require 'CFPropertyList'
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(hash, :convert_unknown_to_string => true)
    plist.save(path, CFPropertyList::List::FORMAT_XML)
    # puts plist.to_str(CFPropertyList::List::FORMAT_XML)
  end

  def self.read_plist(path)
    raise ArgumentError unless File.exist?(path)
    require 'CFPropertyList'
    xml = `plutil -convert xml1 "#{path}" -o -`
    plist = CFPropertyList::List.new
    plist.load_xml_str(xml)
    CFPropertyList.native_types(plist.value)
  end
end
