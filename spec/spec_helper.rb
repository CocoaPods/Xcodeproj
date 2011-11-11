require 'rubygems'
require 'mac_bacon'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

gem 'activesupport', '~> 3.1.1'
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/temporary_directory'
