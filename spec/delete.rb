#!/usr/bin/env ruby

# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "rubygems"
require "pp"
require File.join(File.dirname(__FILE__), "../lib/leadtune")

begin
  p = Leadtune::Prospect.delete do |p|
    p.organization = "LOL"
    p.username = "admin@loleads.com"
    p.password = "admin"
    p.leadtune_host = "http://localhost:8080"
    p.prospect_id = ARGV[0]
  end
rescue Leadtune::LeadtuneError => e
  puts e.to_s
end
