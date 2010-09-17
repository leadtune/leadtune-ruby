#!/usr/bin/env ruby

require "rubygems"
require "pp"
require File.join(File.dirname(__FILE__), "../lib/leadtune")


begin
  p = Leadtune::Prospect.new do |p|
    p.organization = "AcmeU"
    p.username = "admin@acme.edu"
    p.password = "admin"
    # p.leadtune_host = "http://localhost:8080"
    p.prospect_ref = "CRONIN"
  end

  p.get
  pp p.factors

  pp Leadtune::Prospect.new({:prospect_id => "4c92f0e3b34601dd1ecac030",
                             :username => "admin@acme.edu",
                             :password => "admin",
                             :organization => "AcmeU",}).get.factors
rescue Leadtune::Prospect::HttpError => e
  puts e.to_s
end

