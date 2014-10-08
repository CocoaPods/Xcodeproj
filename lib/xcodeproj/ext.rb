begin
  require 'xcodeproj/plist_helper'
rescue LoadError, NameError
  require 'rbconfig'
  if RUBY_VERSION == '1.8.7' && RbConfig::CONFIG['prefix'] =~ %r{^/System/Library/Frameworks/Ruby.framework/}
    $:.unshift(File.expand_path('../../../ext', __FILE__))
    require 'xcodeproj/xcodeproj_ext'
  else
    raise 'The xcodeproj gem is only supported on Ruby versions that include' \
          'the Fiddle API or with Ruby 1.8.7 that came with OS X 10.8.x.'
  end
end
