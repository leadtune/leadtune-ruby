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
  p = Leadtune::Prospect.new({:prospect_id => ARGV[0],
                              :api_key => "h5fvNoTFa9AqzxUgixNcGey7HfZNKiBE9pC39fIH",
                              :target_buyers => ["AcmeU", "Bravo", "ConvU",],
                              :organization => "LOL",
                              :age => rand(30)+18})
  p.leadtune_host = "http://localhost:8080"
  p.put

  pp p.factors
rescue Leadtune::LeadtuneError => e
  puts e.to_s
end

