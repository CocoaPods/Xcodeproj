# Set up coverage analysis
#-----------------------------------------------------------------------------#

if ENV['CI'] || ENV['GENERATE_COVERAGE']
  require 'simplecov'
  require 'coveralls'

  if ENV['CI']
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  elsif ENV['GENERATE_COVERAGE']
    SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  end
  SimpleCov.start do
    add_filter "/spec_helper/"
  end
end

# Set up
#-----------------------------------------------------------------------------#

require 'rubygems'
require 'bacon'
require 'bacon'
require 'mocha-on-bacon'
require 'pretty_bacon'
require 'pathname'

ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'ext').to_s)
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/project'
require 'spec_helper/temporary_directory'


def fixture_path(path)
  File.join(File.dirname(__FILE__), "fixtures", path)
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
