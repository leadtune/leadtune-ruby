#!/usr/bin/env ruby

require "rubygems"
require File.join(File.dirname(__FILE__), "../lib/leadtune/seller")

class Leadtune::Seller

  def sleep=(value)
    $stderr.puts "setting sleep to #{value.inspect}"
    @factors["sleep"] = value
  end

  def post_options_with_sleep
    post_options_without_sleep.merge(:sleep => @factors["sleep"])
  end

  alias_method :post_options_without_sleep, :post_options
  alias_method :post_options, :post_options_with_sleep

end

s = Leadtune::Seller.new do |s|
  s.event = "offers_prepared"
  s.organization = "LOL"
  s.username = "admin@loleads.com"
  s.password = "admin"
  s.email = "test@example.com"
  s.decision = {"target_buyers" => ["AcmeU", "Bravo", "ConvU",]}
  s.leadtune_host = "http://localhost:8080"
  s.sleep = 20
end
s.post

