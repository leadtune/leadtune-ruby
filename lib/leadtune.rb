# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require "array_extensions"
require "hash_extensions"


# For details about the LeadTune API, see: http://leadtune.com/api

module Leadtune #:nodoc:all
end

# Raised when non-2XX responses are received.
class Leadtune::LeadtuneError < RuntimeError ; end 


require "leadtune/prospect"
require "leadtune/rest"
require "leadtune/appraisals"

