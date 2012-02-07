require 'rubygems'
require 'bacon'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'ext').to_s)
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/temporary_directory'
