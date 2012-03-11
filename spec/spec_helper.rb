require 'rubygems'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'ext').to_s)
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/color_output'
require 'spec_helper/project'
require 'spec_helper/temporary_directory'

require 'bacon'
module Bacon
  extend ColorOutput
  summary_at_exit
end

def fixture_path(path)
  File.join(File.dirname(__FILE__), "fixtures", path)
end
