# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

class Array
  # stolen from ActiveSupport
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end
