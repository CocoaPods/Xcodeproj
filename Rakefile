# Bootstrap task
#-----------------------------------------------------------------------------#

desc 'Install dependencies'
task :bootstrap do
  if system('which bundle')
    sh 'bundle install'
  else
    $stderr.puts "\033[0;31m" \
      "[!] Please install the bundler gem manually:\n" \
      '    $ [sudo] gem install bundler' \
      "\e[0m"
    exit 1
  end
end

begin

  task :build do
    title 'Building the gem'
  end

  require 'bundler/gem_tasks'

  # Release tasks
  #-----------------------------------------------------------------------------#

  desc 'Build the gem for distribution'
  task :release_build => :build

  desc 'Runs the tasks necessary for the release of the gem'
  task :pre_release do
    title 'Running pre-release tasks'
    tmp = File.expand_path('../tmp', __FILE__)
    sh "rm -rf '#{tmp}'"
    Rake::Task[:release_build].invoke
  end

  # Always prebuilt for gems!
  Rake::Task[:build].enhance [:pre_release]

  # Travis support
  def on_rvm?
    `which ruby`.strip.include?('.rvm')
  end

  def rvm_ruby_dir
    @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
  end

  #-----------------------------------------------------------------------------#

  namespace :spec do
    desc 'Run all specs'
    task :all do
      puts "\n\033[0;32mUsing #{`ruby --version`.chomp}\033[0m"
      title 'Running the specs'
      sh "bundle exec bacon #{FileList['spec/**/*_spec.rb'].join(' ')}"

      Rake::Task['rubocop'].invoke if RUBY_VERSION >= '1.9.3'
    end

    desc 'Automatically run specs'
    task :kick do
      exec 'bundle exec kicker -c'
    end

    desc 'Run single spec'
    task :single, :spec_file do |_t, args|
      sh "bundle exec bacon #{args.spec_file}"
    end
  end

  desc 'Run all specs'
  task :spec => 'spec:all'

  task :default => :spec

  #-- RuboCop ----------------------------------------------------------------#

  if RUBY_VERSION >= '1.9.3'
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new
  end

rescue LoadError => e
  $stderr.puts "\033[0;31m" \
    '[!] Some Rake tasks haven been disabled because the environment' \
    ' couldn’t be loaded. Be sure to run `rake bootstrap` first.' \
    "\e[0m"
  $stderr.puts e.message
  $stderr.puts e.backtrace
  $stderr.puts
end

# UI Helpers
#-----------------------------------------------------------------------------#

# Prints a title.
#
def title(string)
  puts
  puts yellow(string)
  puts '-' * 80
end

# Prints a subtitle
#
def subtitle(string)
  puts cyan(string)
end

# Colorizes a string to yellow.
#
def yellow(string)
  "\033[0;33m#{string}\e[0m"
end

# Colorizes a string to cyan.
#
def cyan(string)
  "\n\033[0;36m#{string}\033[0m"
end
