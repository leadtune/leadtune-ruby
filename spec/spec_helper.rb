require "rspec"
require File.dirname(__FILE__) + "/../lib/leadtune"

require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock
end
