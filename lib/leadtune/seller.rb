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
  #
  # == Authentication
  # You may specify your username and password by any of the following methods:
  # * config_file -- See #new
  # * ENV values -- +username+ is read from
  #   <tt>ENV["LEADTUNE_SELLER_USERNAME"]</tt>, while +password+ is read from
  #   <tt>ENV["LEADTUNE_SELLER_PASSWORD"]</tt>.
  # * the #username and #password methods
  #
  # Each successive method takes precendence over the preceeding methods, so
  # if you use a config file, you can override the values specified therein by
  # either setting the appropriate environment variables, or by using the
  # #username and #password methods on the Seller object.
  class Seller
    include Validations

    attr_accessor :decision, :username, :password #:nodoc:

    # +config_file+ can be a filename or a file-like object pointing to a YAML
    # file which can include the following keys:
    #
    # * username
    # * password
    #
    # The config file will be read at initialization, but is overwritten by
    # values specified in the environment, or when manually set using the
    # #username or #password methods.
    def initialize(config_file=nil)
      @factors = {}
      @decision = nil
      @config = {}

      determine_environment
      load_config_file(config_file)
      load_authentication
      load_factors
    end

    # Post this lead to the LeadTune Appraiser service.
    # 
    # Return a Response object.
    def post
      CurbFu::debug = true if :sandbox == @environment
      run_validations!
      response = CurbFu.post(post_options, 
                             @factors.merge(:decision => @decision).to_json)
      Response.new(response)
    end


    private 

    def headers
      {"Content-Type" => "application/json",
       "Accept" => "application/json",}
    end

    def post_options
      uri = URI::parse(leadtune_url)
      {:protocol => uri.scheme,
       :username => username,
       :password => password,
       :headers => headers,
       :host => uri.host,
       :port => uri.port,
       :path => "/prospects",}
    end

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

    def load_config_file(config_file) #:nodoc:
      find_config_file(config_file)

      if @config_file
        @config = YAML::load(@config_file)
      end
    end

    def find_config_file(config_file) #:nodoc:
      case config_file
      when String; @config_file = File.open(config_file)
      when File, StringIO; @config_file = config_file
      when nil
        if File.exist?("leadtune-seller.yml")
          @config_file = File.open("leadtune-seller.yml")
        end
      end
    end

    # TODO: check for other methods to automatically determine environment
    def determine_environment #:nodoc:
      if production_detected?
        @environment = :production
      else
        @environment = :sandbox
      end
    end

    def production_detected? #:nodoc:
      "production" == ENV["RAILS_ENV"] ||
        defined?(RAILS_ENV) && "production" == RAILS_ENV
    end

    def production? #:nodoc:
      :production == @environment
    end

    def load_authentication #:nodoc:
      self.username = ENV["LEADTUNE_SELLER_USERNAME"] || @config["username"]
      self.password = ENV["LEADTUNE_SELLER_PASSWORD"] || @config["password"]
    end

    def load_factors #:nodoc:
      self.class.load_factors unless @@factors_loaded
      @@factors_loaded = true
    end

    def leadtune_url(environment) #:nodoc:
      ENV["LEADTUNE_SELLER_URL"] || @config["leadtune_url"] || LEADTUNE_URLS[@environment]
    end

    LEADTUNE_URL_SANDBOX = "https://sandbox-appraiser.leadtune.com".freeze
    LEADTUNE_URL_PRODUCTION = "https://appraiser.leadtune.com".freeze

    LEADTUNE_URLS = {
      #:production => LEADTUNE_URL_PRODUCTION,
      :sandbox => LEADTUNE_URL_SANDBOX,
    }

    @@factors_loaded = false

  end
end
