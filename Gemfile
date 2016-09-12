source 'http://rubygems.org'

gemspec

gem 'claide', :git => 'https://github.com/CocoaPods/CLAide'

# This is the version that ships with OS X 10.10, so be sure we test against it.
# At the same time, the 1.7.7 version won't install cleanly on Ruby > 2.2,
# so we use a fork that makes a trivial change to a macro invocation.
gem 'json', :git => 'https://github.com/segiddins/json.git', :branch => 'seg-1.7.7-ruby-2.2'

gem 'ascii_plist', :git => 'https://github.com/DanToml/ascii_plist.git'

gem 'activesupport', '~> 4.2'

group :development do
  gem 'mocha'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  gem 'rake'

  gem 'codeclimate-test-reporter', :require => nil
  gem 'simplecov'
  gem 'rubocop'
end

group :debugging do
  gem 'kicker'
end
