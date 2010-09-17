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

def setup_leadtune_env
  ENV["LEADTUNE_USERNAME"] = "env@env.com"
  ENV["LEADTUNE_PASSWORD"] = "env_secret"
  ENV["LEADTUNE_ORGANIZATION"] = "env_org"
end

def teardown_leadtune_env
  ENV.delete("LEADTUNE_USERNAME")
  ENV.delete("LEADTUNE_PASSWORD")
  ENV.delete("LEADTUNE_ORGANIZATION")
end

def leadtune_config_file
  StringIO.new <<EOF
username: config_file@config_file.com
password: config_file_secret
organization: config_file_org
EOF
end
