# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xcodeproj', __FILE__)

Gem::Specification.new do |s|
  s.name     = "xcodeproj"
  s.version  = Xcode::VERSION
  s.date     = "2011-11-10"
  s.license  = "MIT"
  s.email    = "eloy.de.enige@gmail.com"
  s.homepage = "https://github.com/alloy/xcodeproj"
  s.authors  = ["Eloy Duran"]

  s.summary     = "Fiddle with Xcode projects. (Requires MacRuby.)"
  s.description = %(
    xcodeproj lets you read and modify Xcode projects from MacRuby. Script 
    boring management tasks or build Xcode-friendly libraries. Includes support
    for Xcode workspaces (.xcworkspace) and configuration files (.xcconfig).
  ).strip.gsub(/\s+/, ' ')

  s.files    = Dir["lib/**/*.rb"] +
               %w{ README.md LICENSE }

  s.require_paths = %w{ lib }

  s.add_runtime_dependency 'activesupport', '~> 3.1.1'
  s.add_runtime_dependency 'i18n', '~> 0.6.0' # only needed for ActiveSupport :-/

  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.6.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
end
