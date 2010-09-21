# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "ruby-debug"
require "rspec"
require File.dirname(__FILE__) + "/../lib/leadtune"

require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock
end

def setup_initializer
  Leadtune::Config.username = "init_user"
  Leadtune::Config.password = "init_secret"
  Leadtune::Config.timeout = 7
  Leadtune::Config.organization = "init_org"
  Leadtune::Config.leadtune_host = "http://localhost.init"
end

def teardown_initializer
  Leadtune::Config.username = nil
  Leadtune::Config.password = nil
  Leadtune::Config.timeout = nil
  Leadtune::Config.organization = nil
  Leadtune::Config.leadtune_host = nil
end

