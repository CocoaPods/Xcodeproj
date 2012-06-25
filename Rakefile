# Travis support
def on_rvm?
  `which ruby`.strip.include?('.rvm')
end

def rvm_ruby_dir
  @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
end

namespace :travis do
  # Used to create the deb package.
  #
  # Known to work with opencflite rev 248.
  task :prepare_deb do
    sh "sudo apt-get install subversion libicu-dev"
    sh "svn co https://opencflite.svn.sourceforge.net/svnroot/opencflite/trunk opencflite"
    sh "cd opencflite && ./configure --target=linux --with-uuid=/usr --with-tz-includes=./include --prefix=/usr/local && make && sudo make install"
    sh "sudo /sbin/ldconfig"
  end

  task :install_opencflite_debs do
    sh "mkdir -p debs"
    Dir.chdir("debs") do
      base_url = "https://github.com/downloads/CocoaPods/OpenCFLite"
      %w{ opencflite1_248-1_i386.deb opencflite-dev_248-1_i386.deb }.each do |deb|
        sh "wget #{File.join(base_url, deb)}" unless File.exist?(deb)
      end
      sh "sudo dpkg -i *.deb"
    end
  end

  task :fix_rvm_include_dir do
    unless File.exist?(File.join(rvm_ruby_dir, 'include'))
      # Make Ruby headers available, RVM seems to do not create a include dir on 1.8.7, but it does on 1.9.3.
      sh "mkdir '#{rvm_ruby_dir}/include'"
      sh "ln -s '#{rvm_ruby_dir}/lib/ruby/1.8/i686-linux' '#{rvm_ruby_dir}/include/ruby'"
    end
  end

  task :setup => [:install_opencflite_debs, :fix_rvm_include_dir]
end

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

begin
  require 'rubygems'
  require 'yard'
  require 'yard/rake/yardoc_task'
  require File.expand_path('../yard_extensions', __FILE__)

  namespace :doc do
    YARD::Rake::YardocTask.new(:generate) do |t|
      t.options = %w{ --default-return=void --hide-void-return --no-private --markup=markdown }
      lib_files = FileList['lib/**/*.rb'].exclude(/inflector\.rb/)
      t.files = lib_files + ['ext/xcodeproj/xcodeproj_ext.c', '-', 'README.md', 'LICENSE']
    end

    desc "Starts a server which re-generates the docs on reload."
    task :server do
      sh "bundle exec yard server --reload --markup=markdown"
    end
  end

rescue LoadError
  puts "[!] Install the required dependencies to generate documentation: $ bundle install"
end

namespace :gem do
  desc "Build the gem"
  task :build do
    sh "gem build xcodeproj.gemspec"
  end

  desc "Install a gem version of the current code"
  task :install => :build do
    require File.expand_path('../lib/xcodeproj', __FILE__)
    sh "gem install xcodeproj-#{Xcodeproj::VERSION}.gem"
  end
end

namespace :spec do
  desc "Run all specs"
  task :all => "ext:cleanbuild" do
    sh "bundle exec bacon #{FileList['spec/**/*_spec.rb'].join(' ')}"
  end

  desc "Automatically run specs"
  task :kick do
    exec "bundle exec kicker -c"
  end
end

desc "Dumps a Xcode project as YAML, meant for diffing"
task :dump_xcodeproj => 'ext:cleanbuild' do
  require 'ext/xcodeproj/xcodeproj_ext'
  require 'yaml'
  hash = Xcodeproj.read_plist(File.join(ENV['xcodeproj'], 'project.pbxproj'))
  objects = hash['objects']
  result = objects.values.map do |object|
    if children = object['children']
      object['children'] = children.map do |uuid|
        child = objects[uuid]
        child['path'] || child['name']
      end.sort
    elsif files = object['files']
      object['files'] = files.map do |uuid|
        build_file = objects[uuid]
        file = objects[build_file['fileRef']]
        file['path']
      end
    elsif file_ref = object['fileRef']
      file = objects[file_ref]
      object['file'] = file['path']
    end
    object
  end
  result.each do |object|
    object.delete('fileRef')
  end
  result = result.sort_by do |object|
    [object['isa'], object['file'], object['path'], object['name']].compact
  end
  puts result.to_yaml
end

desc "Run all specs"
task :spec => 'spec:all'

task :default => :spec
