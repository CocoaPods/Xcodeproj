namespace :ext do
  task :clean do
    sh "cd ext/xcodeproj && rm -f Makefile *.o *.bundle"
  end

  task :build do
    Dir.chdir 'ext/xcodeproj' do
      ruby "extconf.rb"
      sh "make"
    end
  end

  task :cleanbuild => [:clean, :build]
end

desc "Compile the source files (as rbo files)"
task :compile do
  Dir.glob("lib/**/*.rb").each do |file|
    sh "macrubyc #{file} -C -o #{file}o"
  end
end

desc "Remove rbo files"
task :clean do
  sh "rm -f lib/**/*.rbo"
  sh "rm -f lib/**/*.o"
  sh "rm -f *.gem"
end

desc "Install a gem version of the current code"
task :install do
  require 'lib/xcodeproj'
  sh "gem build xcodeproj.gemspec"
  sh "sudo macgem install xcodeproj-#{Xcodeproj::VERSION}.gem"
  sh "sudo macgem compile xcodeproj"
end

namespace :spec do
  task :all => "ext:cleanbuild" do
    sh "bacon spec/*_spec.rb"
  end
end

desc "Dumps a Xcode project as YAML, meant for diffing"
task :dump_xcodeproj do
  require 'yaml'
  hash = NSDictionary.dictionaryWithContentsOfFile(File.join(ENV['xcodeproj'], 'project.pbxproj'))
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
