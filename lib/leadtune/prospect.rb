# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "yaml"
require "curb"
require "uri"

require "leadtune/appraisals"
require "leadtune/rest"
require "leadtune/config"


module Leadtune

  # Simplify the process of submitting prospects to LeadTune for duplicate
  # checking and appraisal.
  #
  # For details about the LeadTune API, see: http://leadtune.com/api
  #
  # == Dynamic Factor Access
  #
  # Getter and setter methods are dynamically defined for factors as they're
  # set. See http://leadtune.com/factors for a list of LeadTune recognized
  # factors.

  class Prospect
    attr_accessor :decision  #:nodoc:

    def initialize(options_and_factors={}, &block)
      @factors = {}
      @decision = nil
      @config = Config.new
      @rest = Rest.new(@config)

      load_options_and_factors(options_and_factors)
      block.call(self) if block_given?
    end

    # Get a prospect from the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def self.get(options_and_factors={}, &block)
      new(options_and_factors, &block).get
    end

    # Post a prospect to the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def self.post(options_and_factors={}, &block)
      new(options_and_factors, &block).post
    end

    # Update a prospect from the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def self.put(options_and_factors={}, &block)
      new(options_and_factors, &block).put
    end

    # Delete a prospect from the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def self.delete(options_and_factors={}, &block)
      new(options_and_factors, &block).delete
    end

    # Get a prospect from the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def get
      json = @rest.get(post_data)
      parse_response(json)
      self
    end

    # Post this prospect to the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def post
      json = @rest.post(post_data)
      parse_response(json)
      self
    end

    # Update a prospect from the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def put
      json = @rest.put(post_data)
      parse_response(json)
      self
    end

    # Delete a prospect from the LeadTune Appraiser service.
    #
    # Raises a Leadtune::LeadtuneError if a non-2XX response is received.

    def delete
      json = @rest.delete(post_data)
      parse_response(json) unless json.nil?
      self
    end

    # The unique +decision_id+ for this prospect.

    def decision_id
      @decision ||= {}
      @decision["decision_id"]
    end

    # The appraisals for this Prospect.
    #
    # The Array returned has been extended to include two methods,
    # +duplicates+ and +non_duplicates+.  Each returns the appraisals of the
    # target_buyers for whom this lead is or is not a known duplicate.

    def appraisals
      @decision ||= {}
      @decision["appraisals"]
    end

    # Return a hash of the factors specified for this Prospect.

    def factors
      @factors
    end

    # Assign an array of organization codes for the prospect's target buyers.

    def target_buyers=(target_buyers)
      unless target_buyers.is_a?(Array)
        raise ArgumentError.new("target_buyers must be an Array")
      end

      @decision = {"target_buyers" => target_buyers}
    end

    # Return an array of organization codes for the prospect's target buyers.

    def target_buyers
      @decision ||= {}
      @decision["target_buyers"] ||= []
    end

    def organization #:nodoc:
      @factors["organization"] || @config.organization
    end

    def prospect_id #:nodoc:
      @factors["prospect_id"]
    end

    def prospect_ref #:nodoc:
      @factors["prospect_ref"]
    end

    def leadtune_host=(host) #:nodoc:
      @config.leadtune_host = host
    end

    def leadtune_host #:nodoc:
      @config.leadtune_host
    end

    def timeout=(timeout) #:nodoc:
      @config.timeout = timeout
    end

    def timeout #:nodoc:
      @config.timeout
    end

    def username=(username)
      @config.username = username
    end

    def password=(password)
      @config.password = password
    end

    def response #:nodoc:
      @rest.response
    end

    def payload #:nodoc:
      post_data.reject {|k,v| CURL_OPTIONS.include?(k)}
    end


    private

    CURL_OPTIONS = ["username", "password", "timeout", "leadtune_host",] #:nodoc:

    def post_data #:nodoc:
      f = @factors.merge("organization" => organization)
      f.merge!("decision" => @decision) if @decision
      f
    end

    def load_options_and_factors(options) #:nodoc:
      load_curl_options(options)
      load_factors(options)
    end

    def load_curl_options(options) #:nodoc:
      CURL_OPTIONS.each do |option|
        @config.send("#{option}=", options.delete(option)) if options[option]
      end
    end

    def load_factors(factors) #:nodoc:
      factors.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

    def parse_response(response) #:nodoc:
      response = response.dup
      load_decision(response)
      load_factors(response)
    end

    def load_decision(response) #:nodoc:
      return unless response.include?("decision")

      @decision = response.delete("decision")
      if @decision.include?("appraisals")
        @decision["appraisals"] = Appraisals.new(@decision["appraisals"])
      end
    end

    def method_missing(name, *args, &block) #:nodoc:
      if /=$/ === name.to_s
        memoize_new_factor(name)
        self.send(name, *args, &block)
      else
        super
      end
    end

    def memoize_new_factor(name) #:nodoc:
      getter_name = name.to_s.sub(/=$/, "")

      self.class.class_eval do
        define_method(name) do |value|
          @factors[getter_name] = value
        end
      end

      unless respond_to?(getter_name)
        self.class.class_eval do
          define_method(getter_name) do
            @factors[getter_name]
          end
        end
      end
    end

  end
end
