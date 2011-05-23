# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

module Leadtune

  class Config #:nodoc:all
    attr_accessor :environment, :leadtune_host, :api_key, :timeout, :query_params

    @@leadtune_host = nil
    @@api_key = nil
    @@organization = nil
    @@timeout = nil
    @@query_params = nil

    def self.api_key=(api_key)
      @@api_key = api_key
    end

    def self.organization=(organization)
      @@organization = organization
    end

    def self.leadtune_host=(leadtune_host)
      @@leadtune_host = leadtune_host
    end

    def self.timeout=(timeout)
      @@timeout = timeout
    end

    def self.query_params=(query_params)
      @@query_params = query_params
    end

    def api_key
      @api_key ||= @@api_key
    end

    def timeout
      @timeout ||= @@timeout || DEFAULT_TIMEOUT
    end

    def query_params
      @query_params ||= @@query_params
    end

    def organization
      @@organization
    end

    def leadtune_host
      @leadtune_host ||= @@leadtune_host || LEADTUNE_HOSTS[environment]
    end

    def environment
      @environment ||= production_environment_detected? ? :production : :sandbox
    end

    def production_environment_detected?
      if ENV.include?("APP_ENV")
        "production" == ENV["APP_ENV"]
      else
        defined?(Rails) && "production" == Rails.env ||
          "production" == ENV["RACK_ENV"] ||
          "production" == ENV["RAILS_ENV"] ||
          defined?(RAILS_ENV) && "production" == RAILS_ENV
      end
    end


    private

    DEFAULT_TIMEOUT = 5
    LEADTUNE_HOST_SANDBOX = "https://sandbox-appraiser.leadtune.com".freeze
    LEADTUNE_HOST_PRODUCTION = "https://appraiser.leadtune.com".freeze
    LEADTUNE_HOSTS = {
      :production => LEADTUNE_HOST_PRODUCTION,
      :sandbox => LEADTUNE_HOST_SANDBOX,
    }
  end
end
