source 'http://rubygems.org'

gemspec

group :development do
  gem 'rake', '~> 10.1.0'   # Ruby 1.8.7
  gem 'mime-types', '< 2.0' # Ruby 1.8.7
  gem 'mocha'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  gem 'kicker'

  if RUBY_VERSION >= '1.9.3'
    gem 'codeclimate-test-reporter', :require => nil
    # Bug: https://github.com/colszowka/simplecov/issues/281
    gem 'simplecov',   '< 0.9'  # Ruby 1.8.7
  end
end

group :documentation do
  gem 'yard'
  gem 'redcarpet'
  gem 'github-markup'
  gem 'pygments.rb'
end
