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

    def initialize(config_file=nil)
      load_config_file_values(config_file)
    end

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
      @@timeout = timeout.to_i
    end

    def username
      @username ||= @@username || ENV["LEADTUNE_USERNAME"] || @config_file_values["username"]
    end

    def password
      @password ||= @@password || ENV["LEADTUNE_PASSWORD"] || @config_file_values["password"]
    end

    def timeout
      @timeout ||= (@@timeout ||
                    ENV["LEADTUNE_TIMEOUT"] || 
                    @config_file_values["timeout"] || 
                    DEFAULT_TIMEOUT).to_i
    end

    def organization
      @@organization || ENV["LEADTUNE_ORGANIZATION"] || @config_file_values["organization"]
    end

    def leadtune_host
      @leadtune_host ||= (ENV["LEADTUNE_HOST"] || 
                          @config_file_values["host"] ||
                          LEADTUNE_HOSTS[environment])
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

    def load_config_file_values(config_file)
      @config_file_values = {}

      find_config_file(config_file) do |config_file|
        @config_file_values = YAML::load(config_file)
      end
    end

    def find_config_file(config_file)
      case config_file
      when String
        yield File.open(config_file)
      when File, StringIO
        yield config_file
      when nil
        if File.exist?("leadtune.yml")
          yield File.open("leadtune.yml") 
        end
      end
    end


    DEFAULT_TIMEOUT = 5
    LEADTUNE_HOST_SANDBOX = "https://sandbox-appraiser.leadtune.com".freeze 
    LEADTUNE_HOST_PRODUCTION = "https://appraiser.leadtune.com".freeze
    LEADTUNE_HOSTS = {
      :production => LEADTUNE_HOST_PRODUCTION,
      :sandbox => LEADTUNE_HOST_SANDBOX,
    }
  end
end
