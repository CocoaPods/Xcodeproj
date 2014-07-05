# Set up coverage analysis
#-----------------------------------------------------------------------------#

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end
CodeClimate::TestReporter.start

# Set up
#-----------------------------------------------------------------------------#

require 'rubygems'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'
require 'pathname'

ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$LOAD_PATH.unshift((ROOT + 'ext').to_s)
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

$LOAD_PATH.unshift((ROOT + 'spec').to_s)
require 'spec_helper/project'
require 'spec_helper/project_helper'
require 'spec_helper/temporary_directory'

def fixture_path(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

class Hash
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    Xcodeproj::Differ.project_diff(self, other, self_key, other_key)
  end

  def recursive_delete(key_to_delete)
    Xcodeproj::Differ.project_diff!(self, key_to_delete)
  end
end

class Array
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    Xcodeproj::Differ.project_diff(self, other, self_key, other_key)
  end
end

class Object
  def recursive_diff(other, self_key = 'self', other_key = 'other')
    Xcodeproj::Differ.project_diff(self, other, self_key, other_key)
  end
end
