# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

# For details about the LeadTune API, see: http://leadtune.com/api

module Leadtune #:nodoc:all
end

# Raised when non-2XX responses are received.
class Leadtune::LeadtuneError < RuntimeError 
  attr_reader :code, :message

  def initialize(code, message)
    @code, @message = code, message
  end

  def to_s
    "#{@code} #{message}"
  end
end 


require "leadtune/util"
require "leadtune/prospect"
require "leadtune/rest"
require "leadtune/appraisals"

