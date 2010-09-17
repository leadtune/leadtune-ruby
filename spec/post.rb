#!/usr/bin/env ruby

require "rubygems"
require "ruby-debug"
require "pp"
require File.join(File.dirname(__FILE__), "../lib/leadtune")

p = Leadtune::Prospect.post do |p|
  p.event = "offers_prepared"
  p.organization = "LOL"
  p.username = "admin@loleads.com"
  p.password = "admin"
  p.email = "test@example.com"
  p.target_buyers = ["AcmeU", "Bravo", "ConvU",]
  #p.leadtune_host = "http://localhost:8080"
end

pp p.factors
pp p.decision_id
