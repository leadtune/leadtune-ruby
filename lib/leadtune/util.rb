# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

module Leadtune
  class Util
    def self.to_params(hash)
      # File merb/core_ext/hash.rb, line 87, with slight tweaks
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

    # stolen from ActiveSupport, with slight tweaks
    def self.extract_options!(args)
      args.last.is_a?(::Hash) ? args.pop : {}
    end
  end
end
