# = LeadTune Lead Seller's API Ruby Gem
#
# http://github.com/leadtune/leadtune-seller <br/>
# Eric Wollesen (mailto:devs@leadtune.com)  <br/>
# Copyright 2010 LeadTune LLC

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require "ruby-debug"
require "yaml"
require "json"
require "curb-fu"
require "uri"
require File.dirname(__FILE__) + "/../object_extensions"

require "seller/validations"
require "seller/response"

module Leadtune

  # Simplify the process of submitting leads to LeadTune for duplicate
  # checking and appraisal.
  # 
  # For details about the LeadTune Seller API, see:
  # http://leadtune.com/api/seller
  #
  #  require "rubygems"
  #  require "leadtune/seller"
  #
  #  seller = Leadtune::Seller.new
  #  seller.event = "offers_prepared"                           # required
  #  seller.organization = "LOL"                                # required
  #  seller.email = "test@example.com"                          # required
  #  seller.decision = {"target_buyers" => ["TB-LOL", "AcmeU"]} # required
  #  seller.username = "admin@loleads.com"                      # required
  #  seller.password = "secret"                                 # required
  #  ... include other factors here, see http://leadtune.com/factors for details
  #  response = seller.post
  class Seller
    include Validations

    attr_accessor :decision, :environment, :username, :password #:nodoc:

    def initialize
      @factors = {}
      @decision = nil

      determine_environment
      load_factors
    end

    # Post this lead to the LeadTune Appraiser service.
    # 
    # Return a Response object.
    def post
      CurbFu::debug = true if :sandbox == determine_environment
      run_validations!
      headers = {"Content-Type" => "application/json",
                 "Accept" => "application/json",}
      uri = URI::parse(ENVIRONMENTS[@environment])
      data = @factors.merge(:decision => @decision).to_json
      response = CurbFu.post({:protocol => uri.scheme,
                              :username => username,
                              :password => password,
                              :headers => headers,
                              :host => uri.host,
                              :port => uri.port,
                              :path => "/prospects",},
                             data)
      Response.new(response)
    end


    private 

    def self.load_factors(file=default_factors_file) #:nodoc:
      factors = YAML::load(file)
      factors.each do |factor|
        define_method(factor["code"].to_sym) do
          @factors[factor["code"]]
        end

        define_method(("%s=" % [factor["code"]]).to_sym) do |value|
          @factors[factor["code"]] = value
        end
      end
    end

    def self.default_factors_file #:nodoc:
      File.open("/Users/ewollesen/src/uber/site/db/factors.yml") # FIXME: magic
    end

    # TODO: check for other methods to automatically determine environment
    def determine_environment #:nodoc:
      if ENV.include?("RAILS_ENV") && "production" == ENV["RAILS_ENV"] ||
          defined?(RAILS_ENV) && "production" == RAILS_ENV
        @environment = :production
      else
        @environment = :sandbox
      end
    end

    def load_factors #:nodoc:
      self.class.load_factors unless @@factors_loaded
      @@factors_loaded = true
    end

    ENVIRONMENTS = {
      #:production => "https://appraiser.leadtune.com",
      :sandbox => "https://sandbox-appraiser.leadtune.com",
    }

    @@factors_loaded = false

  end
end
