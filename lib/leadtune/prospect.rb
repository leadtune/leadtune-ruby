# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "yaml"
require "json"
require "curb"
require "uri"

require "array_extensions"
require "hash_extensions"
require "object_extensions"
require "leadtune/appraisals"


module Leadtune

  # Simplify the process of submitting prospects to LeadTune for duplicate
  # checking and appraisal.
  # 
  # For details about the LeadTune Seller API, see:
  # http://leadtune.com/api/seller
  #
  #  require "rubygems"
  #  require "leadtune"
  #
  #  prospect = Leadtune::Prospect.post({
  #    :username => "admin@loleads.com"        # required (See Authentication)
  #    :password => "secret"                   # required (See Authentication)
  #    :organization => "LOL",                 # required (See Authentication)
  #    :event => "offers_prepared",            # required
  #    :email => "test@example.com"            # required
  #    :target_buyers => ["TB-LOL", "AcmeU",]  # required
  #    ... include optional factors here, see http://leadtune.com/factors for details
  #  })
  #
  # <em>Or alternately</em>
  #
  #  prospect = Leadtune::Prospect.post do |p|
  #    p.event = "offers_prepared"
  #    p.organization = "LOL"   
  #    ... and so on
  #  end
  #
  # == Authentication
  #
  # Authentication credentials can be specified in several methods, as
  # detailed below:
  #
  # === Configuration File
  #
  # The configuration file can be specified when calling #new.  If no file is
  # specified, the gem will also look for +leadtune.yml+ in the current
  # directory.
  #
  # ==== Format
  # 
  # The configuration file is a YAML file, an example of which is:
  #  username: me@mycorp.com
  #  password: my_secret
  #  organization: MYC
  #--
  #  host: http://localhost:8080
  #++
  #
  # === Environment Variables
  # 
  # Your username, password, and organization can be specified in the
  # +LEADTUNE_USERNAME+, +LEADTUNE_PASSWORD+, and +LEADTUNE_ORGANIZATION+
  # environment variables. <em>These values take precedence over values read
  # from a configuration file.</em>
  #
  # === Factors Hash
  #
  # When initializing your Prospect, simply include your username, password,
  # and organization along with any other factors you wish to
  # submit. <em>These values take precedence over values read from environment
  # variables, or a configuration file.</em>
  #
  # === Instance Methods
  #
  # You can also set your username, password, and organization by calling the
  # Leadtune::Prospect object's <tt>\#username</tt>, <tt>\#password</tt>, and
  # <tt>\#organization</tt> methods. <em>These values take precedence over
  # values read from environment variables, a configuration file, or the
  # factors hash.</em>
  #
  # == Dynamic Factor Access
  #
  # Getter and setter methods are dynamically defined for factors as they're
  # set. See http://leadtune.com/factors for a list of LeadTune recognized
  # factors.
  #
  # == Automatic Environment Determination
  #
  # At initialization, the Prospect class will attempt to determine your
  # application's current environment.  If a production environment is
  # detected, the Prospect will post prospects to LeadTune's production host.
  # Otherwise prospects will be posted to LeadTune's sandbox host.  The
  # environment can be overriden via the APP_ENV environment variable, which
  # takes precedence over all other methods.
  #
  #--
  #
  # The host used by the Prospect object can be manually overriden via the
  # LEADTUNE_HOST environment variable, the +host+ configuration file value,
  # or the #leadtune_host method as well.

  class Prospect
    attr_accessor :decision, :environment, :username, :password, :timeout #:nodoc:

    # Initialize a new Leadtune::Prospect object.  
    #
    # [+config_file+] An optional filename or a file-like object, see
    #                 Authentication above.
    # [+factors+]     A hash of factors with which to initialize the Prospect

    def initialize(*args, &block)
      @factors = {}
      @decision = nil
      @config = {}

      load_config_file(args.first)
      load_options(args.extract_options!)

      block.call(self) if block_given?
    end

    def self.get(options={}, &block)
      new(options, &block).get
    end

    def self.post(options={}, &block)
      new(options, &block).post
    end

    # Get a prospect from LeadTune.

    def get
      curl = build_curl_easy_object_get
      curl.http("GET")

      parse_response(curl.body_str)
      self
    end

    # Post this prospect to the LeadTune Appraiser service.

    def post
      curl = build_curl_easy_object_post
      curl.http("POST")

      parse_response(curl.body_str)
      self
    end

    # The unique +decision_id+ for this prospect.

    def decision_id
      @decision ||= {}
      @decision["decision_id"]
    end

    # The appraisals for this Response.
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

    # Assign an array of organization codes for the prospects target buyers.

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

    def timeout #:nodoc:
      @timeout ||= 
        (ENV["LEADTUNE_TIMEOUT"] || @config["timeout"] || DEFAULT_TIMEOUT).to_i
    end

    def username
      @username ||= ENV["LEADTUNE_USERNAME"] || @config["username"]
    end

    def password
      @password ||= ENV["LEADTUNE_PASSWORD"] || @config["password"]
    end

    def organization
      @factors["organization"] ||= 
        ENV["LEADTUNE_ORGANIZATION"] || @config["organization"]
    end
    
    def prospect_id
      @factors["prospect_id"]
    end

    def prospect_ref
      @factors["prospect_ref"]
    end


    private 

    def load_config_file(config_file) #:nodoc:
      find_config_file(config_file)

      if @config_file
        @config = YAML::load(@config_file)
      end
    end

    def find_config_file(config_file) #:nodoc:
      @config_file = case config_file
                     when String
                       File.open(config_file)
                     when File, StringIO
                       config_file
                     when nil
                       if File.exist?("leadtune.yml")
                         File.open("leadtune.yml") 
                       end
                     end
    end

    def environment #:nodoc:
      @environment ||= production_environment_detected? ? :production : :sandbox
    end

    def production_environment_detected? #:nodoc:
      if ENV.include?("APP_ENV")
        "production" == ENV["APP_ENV"]
      else
        defined?(Rails) && Rails.env.production? ||
          "production" == ENV["RACK_ENV"] ||
          "production" == ENV["RAILS_ENV"] ||
          defined?(RAILS_ENV) && "production" == RAILS_ENV
      end
    end

    def build_curl_easy_object(&block) #:nodoc:
      Curl::Easy.new do |curl|
        curl.http_auth_types = [:basic,]
        curl.username = username
        curl.password = password
        curl.timeout = timeout 
        curl.headers = default_headers
        curl.on_failure do |curl, code|
          raise LeadtuneError.new("#{curl.response_code} #{curl.body_str}")
        end
        #curl.verbose = true
        yield curl
      end
    end

    def default_headers #:nodoc:
      {"Content-Type" => "application/json",
       "Accept" => "application/json",}
    end

    def build_curl_easy_object_post #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = URI.join(leadtune_host, "/prospects").to_s
        curl.post_body = @factors.merge(:decision => @decision).to_json
      end
    end

    def build_curl_easy_object_get #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_get_url
      end
    end

    def build_get_url
      path = "/prospects"
      path += "/#{prospect_id}" if prospect_id
      params = {:organization => organization,}
      params.merge!(:prospect_ref => prospect_ref) if prospect_ref

      URI.join(leadtune_host, path, "?" + params.to_params).to_s
    end

    def load_options(options) #:nodoc:
      self.username = options.delete("username") if options.include?("username")
      self.password = options.delete("password") if options.include?("password")
      load_factors(options)
    end

    def load_factors(factors)
      factors.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

    def parse_response(json)
      json_obj = JSON::parse(json)
      load_decision(json_obj)
      load_factors(json_obj)
    end

    def load_decision(json_obj)
      return unless json_obj.include?("decision")

      @decision = json_obj.delete("decision")
      if @decision.include?("appraisals")
        @decision["appraisals"] = Appraisals.new(@decision["appraisals"])
      end
    end

    def method_missing(name, *args, &block) #:nodoc
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

    # Override the normal host

    def leadtune_host=(host) #:nodoc:
      @leadtune_host = host
    end

    def leadtune_host #:nodoc:
      @leadtune_host || 
        ENV["LEADTUNE_HOST"] || 
        @config["host"] || 
        LEADTUNE_HOSTS[environment]
    end

    LEADTUNE_HOST_SANDBOX = "https://sandbox-appraiser.leadtune.com".freeze
    LEADTUNE_HOST_PRODUCTION = "https://appraiser.leadtune.com".freeze

    LEADTUNE_HOSTS = {
      :production => LEADTUNE_HOST_PRODUCTION,
      :sandbox => LEADTUNE_HOST_SANDBOX,
    }

    DEFAULT_TIMEOUT = 5

    @@factors_loaded = false
    @@factors = []

  end
end
