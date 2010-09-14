# -*- encoding: utf-8 -*-
require File.expand_path("../lib/leadtune/seller/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "leadtune-seller"
  s.version     = Leadtune::Seller::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Eric Wollesen"]
  s.email       = ["devs@leadtune.com"]
  s.homepage    = "http://github.com/organizations/leadtune/leadtune-seller"
  s.summary     = "LeadTune Seller's Gem"
  s.description = "LeadTune Seller's Gem"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
