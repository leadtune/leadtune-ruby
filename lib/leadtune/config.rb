# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

module Leadtune

  class Config #:nodoc:all

    attr_accessor :environment, :leadtune_host, :username, :password, :timeout

    @@leadtune_host = nil
    @@username = nil
    @@password = nil
    @@organization = nil
    @@timeout = nil

    def self.username=(username)
      @@username = username
    end

    def self.password=(password)
      @@password = password
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

    def username
      @username ||= @@username
    end

    def password
      @password ||= @@password
    end

    def timeout
      @timeout ||= @@timeout || DEFAULT_TIMEOUT
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
        defined?(Rails) && Rails.env.production? ||
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
