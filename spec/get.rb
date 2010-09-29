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
  p = Leadtune::Prospect.get({
    :organization => "AcmeU",
    :username => "admin@acme.edu",
    :password => "admin",
    # :leadtune_host => "http://localhost:8080",
    :prospect_ref => "CRONIN",
    # :prospect_id => "4ca3bae9a09801dd413d445c",
  })
  pp p.factors

  pp Leadtune::Prospect.new({:prospect_id => "4ca3bd94a09801dd5b3d445c",
                             :username => "admin@acme.edu",
                             :password => "admin",
                             :organization => "AcmeU",}).get.factors
rescue Leadtune::LeadtuneError => e
  puts e.to_s
end

