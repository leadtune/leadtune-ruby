# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

class Object

  # Return true if the given object is non-nil, and, if applicable, non-empty.
  # Similar to an method of the same name provided by Rails.

  def present?
    case self
    when String
      !empty? && !nil?
    when Hash
      !empty?
    when NilClass
      false
    else
      raise RuntimeError.new("Not handled: #{self.class}")
    end
  end
end
