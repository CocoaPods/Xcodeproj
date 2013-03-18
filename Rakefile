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
    sh "cd ext/xcodeproj && rm -f Makefile *.o *.bundle"
  end

  desc "Build the ext"
  task :build do
    Dir.chdir 'ext/xcodeproj' do
      if on_rvm?
        sh "CFLAGS='-I#{rvm_ruby_dir}/include' ruby extconf.rb"
      else
        sh "ruby extconf.rb"
      end
      sh "make"
    end
  end

  desc "Clean and build the ext"
  task :cleanbuild => [:clean, :build]
end

#-----------------------------------------------------------------------------#

namespace :gem do
  def gem_version
    require File.expand_path('../lib/xcodeproj', __FILE__)
    Xcodeproj::VERSION
  end

  def gem_filename
    "xcodeproj-#{gem_version}.gem"
  end

  desc "Build the gem"
  task :build do
    sh "gem build xcodeproj.gemspec"
  end

  desc "Install a gem version of the current code"
  task :install => :build do
    sh "gem install #{gem_filename}"
  end

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

    unless ENV['SKIP_CHECKS']
      if `git symbolic-ref HEAD 2>/dev/null`.strip.split('/').last != 'master'
        $stderr.puts "[!] You need to be on the `master' branch in order to be able to do a release."
        exit 1
      end

      if `git tag`.strip.split("\n").include?(gem_version)
        $stderr.puts "[!] A tag for version `#{gem_version}' already exists. Change the version in lib/xcodeproj.rb"
        exit 1
      end

      puts "You are about to release `#{gem_version}', is that correct? [y/n]"
      exit if $stdin.gets.strip.downcase != 'y'

      diff_lines = `git diff --name-only`.strip.split("\n")

      if diff_lines.size == 0
        $stderr.puts "[!] Change the version number yourself in lib/xcodeproj.rb"
        exit 1
      end

      if !diff_lines.all? { |f| %w{ Gemfile.lock lib/xcodeproj.rb }.include?(f) }
        $stderr.puts "[!] Only change the version number in a release commit!"
        exit 1
      end
    end

    puts "* Running specs"
    silent_sh('rake spec:all')

    tmp = File.expand_path('../tmp', __FILE__)
    tmp_gems = File.join(tmp, 'gems')

    Rake::Task['gem:build'].invoke

    puts "* Testing gem installation (tmp/gems)"
    silent_sh "rm -rf '#{tmp}'"
    silent_sh "gem install --install-dir='#{tmp_gems}' #{gem_filename}"

    # puts "* Building examples from gem (tmp/gems)"
    # ENV['GEM_HOME'] = ENV['GEM_PATH'] = tmp_gems
    # ENV['PATH']     = "#{tmp_gems}/bin:#{ENV['PATH']}"
    # ENV['FROM_GEM'] = '1'
    # silent_sh "rake examples:build"

    # Then release
    sh "git commit Gemfile.lock lib/xcodeproj.rb -m 'Release #{gem_version}'"
    sh "git tag -a #{gem_version} -m 'Release #{gem_version}'"
    sh "git push origin master"
    sh "git push origin --tags"
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
