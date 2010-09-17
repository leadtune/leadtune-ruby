# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require "array_extensions"
require "hash_extensions"
require "object_extensions"


# For details about the LeadTune API, see: http://leadtune.com/api
module Leadtune
  class LeadtuneError < RuntimeError ; end
end


require "leadtune/prospect"
require "leadtune/rest"
require "leadtune/appraisals"

