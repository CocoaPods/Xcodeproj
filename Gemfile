source 'https://rubygems.org'

gemspec

gem 'claide', :git => 'https://github.com/CocoaPods/CLAide'
gem 'json'

group :development do
  gem 'bacon'
  gem 'mocha', '~> 1.2.0'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  gem 'rake', '~> 12.0'

  gem 'codeclimate-test-reporter', '~> 0.4.1', :require => nil
  gem 'rubocop', '<= 1.91.0'
  gem 'rubocop-ast', '<= 1.50.0' # pin to prevent pulling deps that drop 2.7 support
  gem 'parallel', '< 2.0' # pin to prevent pulling deps that drop 2.7 support
  gem 'simplecov'
end

group :debugging do
  gem 'kicker'
end
