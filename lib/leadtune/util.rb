# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

module Leadtune
  class Util

    # File merb/core_ext/hash.rb, line 87, with slight tweaks

    def self.to_params(hash)
      params = ''
      stack = []

      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << [k,v]
        else
          params << "#{k}=#{v}&"
        end
      end

      stack.each do |parent, sub_hash|
        sub_hash.each do |k, v|
          if v.is_a?(Hash)
            stack << ["#{parent}[#{k}]", v]
          else
            params << "#{parent}[#{k}]=#{v}&"
          end
        end
      end

      params.chop! # trailing &
      params
    end
  end
end
