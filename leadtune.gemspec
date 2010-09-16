# -*- encoding: utf-8 -*-
require File.expand_path("../lib/leadtune/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "leadtune"
  s.version     = Leadtune::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Eric Wollesen"]
  s.email       = ["devs@leadtune.com"]
  s.homepage    = "http://github.com/leadtune/leadtune-ruby"
  s.summary     = "LeadTune Ruby API Gem"
  s.description = "LeadTune Ruby API Gem"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
