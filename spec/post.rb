#!/usr/bin/env ruby

require "rubygems"
require "pp"
require File.join(File.dirname(__FILE__), "../lib/leadtune")

class Leadtune::Prospect
  def sleep=(value)
    @factors["sleep"] = value
  end
end

p = Leadtune::Prospect.post do |p|
  p.event = "offers_prepared"
  p.organization = "LOL"
  p.username = "admin@loleads.com"
  p.password = "admin"
  p.email = "test@example.com"
  p.target_buyers = ["AcmeU", "Bravo", "ConvU",]
  #p.leadtune_host = "http://localhost:8080"
  unless /leadtune/ === p.send(:leadtune_host)
    p.sleep = 20
  end
end

pp p.factors
pp p.decision_id
