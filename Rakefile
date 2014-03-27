# Travis support
def on_rvm?
  `which ruby`.strip.include?('.rvm')
end

def rvm_ruby_dir
  @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
end

#-----------------------------------------------------------------------------#

namespace :ext do
  desc "Clean the ext files"
  task :clean do
    title "Cleaning extension"
    sh "cd ext/xcodeproj && rm -f Makefile *.o *.bundle prebuilt/**/*.o prebuilt/**/*.bundle"
  end

  desc "Build the ext"
  task :build do
    title "Building the extension"
    Dir.chdir 'ext/xcodeproj' do
      if on_rvm?
        sh "CFLAGS='-I#{rvm_ruby_dir}/include' ruby extconf.rb"
      else
        sh "ruby extconf.rb"
      end
      sh "make"
    end
  end

  desc "Pre-compile the ext for default Ruby on 10.8 and 10.9"
  task :precompile do
    title "Pre-compiling the extension"
    versions = Dir.glob(File.expand_path('../ext/xcodeproj/prebuilt/*darwin*', __FILE__)).sort
    versions.each do |version|
      Dir.chdir version do
        subtitle "#{File.basename(version)}"
        sh "make"
      end
    end
  end

  desc "Clean and build the ext"
  task :cleanbuild => [:clean, :build]
end

#-----------------------------------------------------------------------------#

namespace :gem do
  def gem_version
    require File.expand_path('../lib/xcodeproj/gem_version', __FILE__)
    Xcodeproj::VERSION
  end

  def gem_filename
    "xcodeproj-#{gem_version}.gem"
  end

  desc "Build the gem"
  task :build => 'ext:clean' do
    title "Building the gem"
    sh "gem build xcodeproj.gemspec"
  end

  desc "Install a gem version of the current code"
  task :install => :build do
    sh "gem install #{gem_filename}"
  end

  desc "Build the gem for distribution"
  task :release_build => ['ext:clean', 'ext:precompile', :build]

  def silent_sh(command)
    output = `#{command} 2>&1`
    unless $?.success?
      puts output
      exit 1
    end
    output
  end

  desc "Run all specs, build and install gem, commit version change, tag version change, and push everything"
  task :release do

    title "Releasing..."

    subtitle "Running checks"
    unless ENV['SKIP_CHECKS']
      if `git symbolic-ref HEAD 2>/dev/null`.strip.split('/').last != 'master'
        $stderr.puts "[!] You need to be on the `master' branch in order to be able to do a release."
        exit 1
      end

      if `git tag`.strip.split("\n").include?(gem_version)
        $stderr.puts "[!] A tag for version `#{gem_version}' already exists. Change the version in lib/xcodeproj.rb"
        exit 1
      end

      diff_lines = `git diff --name-only`.strip.split("\n")
      diff_lines.delete('CHANGELOG.md')

      if diff_lines.size == 0
        $stderr.puts "[!] Change the version number yourself in lib/xcodeproj.rb"
        exit 1
      end

      not_allowed_files = diff_lines - ['CHANGELOG.md', 'lib/xcodeproj/gem_version.rb', 'Gemfile.lock']
      unless not_allowed_files.empty?
        $stderr.puts "[!] Only change the version number in a release commit! `#{not_allowed_files}`"
        exit 1
      end

      puts "You are about to release `#{gem_version}', is that correct? [y/n]"
      exit if $stdin.gets.strip.downcase != 'y'
    end

    subtitle "Running specs"
    silent_sh('rake spec:all')

    tmp = File.expand_path('../tmp', __FILE__)
    tmp_gems = File.join(tmp, 'gems')

    Rake::Task['gem:release_build'].invoke

    subtitle "Testing gem installation (tmp/gems)"
    silent_sh "rm -rf '#{tmp}'"
    silent_sh "gem install --install-dir='#{tmp_gems}' #{gem_filename}"

    # puts "* Building examples from gem (tmp/gems)"
    # ENV['GEM_HOME'] = ENV['GEM_PATH'] = tmp_gems
    # ENV['PATH']     = "#{tmp_gems}/bin:#{ENV['PATH']}"
    # ENV['FROM_GEM'] = '1'
    # silent_sh "rake examples:build"

    # Then release
    subtitle "Committing & pushing the repo"
    sh "git commit -am 'Release #{gem_version}'"
    sh "git tag -a #{gem_version} -m 'Release #{gem_version}'"
    sh "git push origin master"
    sh "git push origin --tags"

    subtitle "Pushing the gem"
    sh "gem push #{gem_filename}"
  end
end

#-----------------------------------------------------------------------------#

namespace :spec do
  desc "Run all specs"
  task :all => "ext:cleanbuild" do
    ENV['GENERATE_COVERAGE'] = 'true'
    sh "bundle exec bacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
  end

  desc "Automatically run specs"
  task :kick do
    exec "bundle exec kicker -c"
  end

  desc "Run single spec"
  task :single, :spec_file do |t, args|
    sh "bundle exec bacon #{args.spec_file}"
  end
end

#-----------------------------------------------------------------------------#

desc 'Install dependencies'
task :bootstrap, :use_bundle_dir? do |t, args|
  options = []
  options << "--without=documentation"
  options << "--path ./travis_bundle_dir" if args[:use_bundle_dir?]
  sh "bundle install #{options * ' '}"
end

desc "Run all specs"
task :spec => 'spec:all'

task :default => :spec

# UI
#-----------------------------------------------------------------------------#

# Prints a title.
#
def title(string)
  puts
  puts "-" * 80
  puts green(string)
  puts "-" * 80
  puts
end

def subtitle(string)
  puts yellow(string)
end

def error(string)
  raise "[!] #{red(string)}"
end

# Colorizes a string to green.
#
def green(string)
  "\033[0;32m#{string}\e[0m"
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

def cyan(string)
  "\033[0;36m#{string}\033[0m"
end
