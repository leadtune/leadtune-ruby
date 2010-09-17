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
  p = Leadtune::Prospect.get({:prospect_id => "4c93fda2b34601ddb7d1c030",
                              :username => "admin@acme.edu",
                              :password => "admin",
                              :organization => "AcmeU",})
  p.browser_family = "Firefox"
  p.leadtune_host = "http://localhost:8080"
  p.put

  p = Leadtune::Prospect.get({:prospect_id => "4c92f8d6b34601dd5ecac030",
                              :username => "admin@acme.edu",
                              :password => "admin",
                              :organization => "AcmeU",})
  pp p.factors

rescue Leadtune::LeadtuneError => e
  puts e.to_s
end

