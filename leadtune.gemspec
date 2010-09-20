# -*- encoding: utf-8; mode: ruby; -*-

# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

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
  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "rspec", "= 2.0.0.beta.19"
  s.add_development_dependency "rspec-core", "= 2.0.0.beta.19"
  s.add_development_dependency "rspec-expectation", "= 2.0.0.beta.19"
  s.add_development_dependency "rspec-mocks", "= 2.0.0.beta.19"
  s.add_development_dependency "webmock"#, "http://github.com/phiggins/webmock.git"

  s.add_dependency("rake")
  s.add_dependency("curb")
  s.add_dependency("json")
  s.add_dependency("tcpsocket-wait")
  s.add_dependency("activemodel")

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
