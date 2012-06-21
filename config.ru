require 'rubygems'

require 'pathname'
ROOT = Pathname.new(__FILE__)

$:.unshift((ROOT + 'ext').to_s)
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'
require './lib/xcodeproj/server'

Xcodeproj::Server.project_path = Dir.pwd + "/spec/fixtures/AFNetworking iOS Example.xcodeproj"
run Xcodeproj::Server
