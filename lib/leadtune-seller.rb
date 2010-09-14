require "ruby-debug"
require "yaml"
require "json"
require File.join(File.dirname(__FILE__), "object_extensions")
require "active_model"
require "curb-fu"
require "uri"

module Leadtune
  module Seller
    class Base 
      include ActiveModel::Validations

      validates :event, :organization, :decision, :username, :password, :presence => true
      validate :email_or_email_hash_required

      attr_accessor :decision
      attr_accessor :environment

      attr_writer :username, :password

      ENVIRONMENTS = {
        #:production => "https://appraiser.leadtune.com",
        :sandbox => "https://sandbox-appraiser.leadtune.com",
      }

      def initialize
        @factors = {}
        @decision = nil
        determine_environment
        load_factors 
      end

      def load_factors
        self.class.load_factors unless @factors_loaded
        @factors_loaded = true
      end

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
      end


      protected

      def self.load_factors(file=default_factors_file)
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

      def self.default_factors_file
        File.open("/Users/ewollesen/src/uber/site/db/factors.yml") # FIXME: magic
      end

      # TODO: check for other methods to automatically determine environment
      def determine_environment
        if ENV.include?("RAILS_ENV") && "production" == ENV["RAILS_ENV"] ||
            defined?(RAILS_ENV) && "production" == RAILS_ENV
          @environment = :production
        else
          @environment = :sandbox
        end
      end
      def username
        @username
      end

      def password
        @password
      end

      def email_or_email_hash_required
        unless @factors["email_hash"].present? || @factors["email"].present?
          errors.add(:base, "email or email_hash are required fields")
        end
      end

    end
  end
end
