dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module Leadtune
  class LeadtuneError < RuntimeError ; end
end

require "leadtune/prospect"

