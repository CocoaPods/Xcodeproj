# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xcodeproj', __FILE__)

Gem::Specification.new do |s|
  s.name     = "xcodeproj"
  s.version  = Xcodeproj::VERSION
  s.license  = "MIT"
  s.email    = "eloy.de.enige@gmail.com"
  s.homepage = "https://github.com/cocoapods/xcodeproj"
  s.authors  = ["Eloy Duran"]

  s.summary     = "Create and modify Xcode projects from Ruby."
  s.description = %(
    Xcodeproj lets you create and modify Xcode projects from Ruby. Script
    boring management tasks or build Xcode-friendly libraries. Also includes
    support for Xcode workspaces (.xcworkspace) and configuration files (.xcconfig).
  ).strip.gsub(/\s+/, ' ')

  s.extensions    = "ext/xcodeproj/extconf.rb"
  s.files         = Dir["lib/**/*.rb"] + Dir["ext/xcodeproj/{extconf.rb,xcodeproj_ext.c}"] + %w{ README.md LICENSE }
  s.executables   = %w{ xcodeproj }
  s.require_paths = %w{ ext lib }

  s.add_runtime_dependency 'activesupport', '~> 3.2.13'
  s.add_runtime_dependency 'colored',       '~> 1.2'

  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.6.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
end
