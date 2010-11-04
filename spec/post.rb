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
  p = Leadtune::Prospect.post do |p|
    p.organization = "LOL"
    p.api_key = "h5fvNoTFa9AqzxUgixNcGey7HfZNKiBE9pC39fIH"
    # p.leadtune_host = "https://staging-appraiser.leadtune.com"
    # p.leadtune_host = "https://sandbox-appraiser.leadtune.com"
    p.leadtune_host = "http://localhost:8080"

    p.event = "offers_prepared"
    p.email = "test@example.com"
    p.target_buyers = ["AcmeU", "Bravo", "ConvU",]
  end
  pp p.factors
  `/bin/echo -n #{p.prospect_id} | pbcopy 2>&1 > /dev/null`
rescue Leadtune::LeadtuneError => e
  puts e.to_s
end
