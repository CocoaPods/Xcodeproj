# In case a binary built for the current Ruby exists, use that, otherwise see
# if a prebuilt binary exists for the current platform and Ruby version.
begin
  require 'xcodeproj/xcodeproj_ext'
rescue LoadError
  require "xcodeproj/prebuilt/#{RUBY_PLATFORM}-#{RUBY_VERSION}/xcodeproj_ext"
end
