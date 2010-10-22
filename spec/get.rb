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
    :organization => "LOL",
    :username => "admin@loleads.com",
    :password => "admin",
    # :leadtune_host => "https://staging-appraiser.leadtune.com",
    # :leadtune_host => "https://sandbox-appraiser.leadtune.com",
    :leadtune_host => "http://localhost:8080",

    :prospect_id => ARGV[0],
  })
rescue Leadtune::LeadtuneError => e
  puts e.to_s
else
  pp p.factors
end

