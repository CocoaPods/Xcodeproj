# encoding: utf-8

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

  # Common Build settings
  #-----------------------------------------------------------------------------#

  namespace :common_build_settings do
    PROJECT_PATH = 'Project/Project.xcodeproj'

    task :prepare do
      verbose false
      cd 'spec/fixtures/CommonBuildSettings'
    end

    desc "Create a new empty project"
    task :new_project => [:prepare] do
      verbose false
      Bundler.require 'xcodeproj'
      title "Setup Boilerplate"

      confirm "Delete existing fixture project and all data"
      rm_rf 'Project/*'

      subtitle "Create a new fixture project"
      Xcodeproj::Project.new(PROJECT_PATH).save

      subtitle "Open the project …"
      sh 'open "Project/Project.xcodeproj"'
    end

    desc "Interactive walkthrough for creating fixture targets"
    task :targets => [:prepare] do
      verbose false
      Bundler.require 'xcodeproj'

      title "Create Targets"
      subtitle "You will be guided how to *manually* create the needed targets."
      subtitle "Each target name will been copied to your clipboard."
      confirm "Make sure you have nothing unsaved there"

      targets = {
        "Objc_iOS_Native"         => { platform: :ios, type: :application,     language: :objc,  how: "iOS > Master-Detail Application > Language: Objective-C" },
        "Swift_iOS_Native"        => { platform: :ios, type: :application,     language: :swift, how: "iOS > Master-Detail Application > Language: Swift" },
        "Objc_iOS_Framework"      => { platform: :ios, type: :framework,       language: :objc,  how: "iOS > Cocoa Touch Framework > Language: Objective-C" },
        "Swift_iOS_Framework"     => { platform: :ios, type: :framework,       language: :swift, how: "iOS > Cocoa Touch Framework > Language: Swift" },
        "Objc_iOS_StaticLibrary"  => { platform: :ios, type: :static_library,  language: :objc,  how: "iOS > Cocoa Touch Static Library" },
        "Objc_OSX_Native"         => { platform: :osx, type: :application,     language: :objc,  how: "OSX > Cocoa Application > Language: Objective-C" },
        "Swift_OSX_Native"        => { platform: :osx, type: :application,     language: :swift, how: "OSX > Cocoa Application > Language: Swift" },
        "Objc_OSX_Framework"      => { platform: :osx, type: :framework,       language: :objc,  how: "OSX > Cocoa Framework > Language: Objective-C" },
        "Swift_OSX_Framework"     => { platform: :osx, type: :framework,       language: :swift, how: "OSX > Cocoa Framework > Language: Swift" },
        "Objc_OSX_StaticLibrary"  => { platform: :osx, type: :static_library,  language: :objc,  how: "OSX > Library > Type: Static" },
        "Objc_OSX_DynamicLibrary" => { platform: :osx, type: :dynamic_library, language: :objc,  how: "OSX > Library > Type: Dynamic" },
        "OSX_Bundle"              => { platform: :osx, type: :bundle,                            how: "OSX > Bundle" },
      }

      targets.each do |name, attributes|
        begin
          sh "printf '#{name}' | pbcopy"
          confirm "Create a target named '#{name}' by: #{attributes[:how]}", false

          project = Xcodeproj::Project.open(PROJECT_PATH)
          raise "Project couldn't be opened." if project.nil?

          target = project.targets.find { |t| t.name == name }
          raise "Target wasn't found." if target.nil?

          raise "Platform doesn't match." unless target.platform_name == attributes[:platform]
          raise "Type doesn't match."     unless target.symbol_type   == attributes[:type]

          debug_config = target.build_configurations.find { |c| c.name == 'Debug' }
          raise "Debug configuration is missing" if debug_config.nil?

          release_config = target.build_configurations.find { |c| c.name == 'Release' }
          raise "Release configuration is missing" if release_config.nil?

          is_swift_present  = debug_config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] != nil
          is_swift_expected = attributes[:language] == :swift
          raise "Language doesn't match." unless is_swift_present == is_swift_expected

          puts green("Target matches.")
          puts
        rescue StandardError => e
          puts "#{red(e.message)} Try again."
          retry
        end
      end

      puts green("All targets were been successfully created.")
    end

    desc "Dump the build settings of the fixture project to xcconfig files"
    task :dump => [:prepare] do
      verbose false
      sh "../../../bin/xcodeproj config-dump Project/Project.xcodeproj configs"
    end

    desc "Recreate the xcconfig files for the fixture project targets from scratch"
    task :rebuild => [
      :new_project,
      :targets,
      :dump,
    ]
  end

  #-----------------------------------------------------------------------------#

  namespace :spec do
    desc 'Run all specs'
    task :all do
      puts "\n\033[0;32mUsing #{`ruby --version`.chomp}\033[0m"
      title 'Running the specs'
      sh "bundle exec bacon #{FileList['spec/**/*_spec.rb'].join(' ')}"

      Rake::Task['rubocop'].invoke
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

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['lib', 'spec']
  end

rescue LoadError, NameError => e
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

# Colorizes a string to red.
#
def red(string)
  "\033[0;31m#{string}\e[0m"
end

# Colorizes a string to green.
#
def green(string)
  "\033[0;32m#{string}\e[0m"
end

# Colorizes a string to cyan.
#
def cyan(string)
  "\n\033[0;36m#{string}\033[0m"
end

def confirm(message, decline_by_default=true)
  options = ['y', 'n']
  options[decline_by_default ? 1 : 0].upcase!
  print yellow("#{message}: [#{options.join('/')}] ")
  input = STDIN.gets.chomp
  if input == options[1].downcase || (input == '' && decline_by_default)
    puts red("Aborted by user.")
    exit 1
  end
end
