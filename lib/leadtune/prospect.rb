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
require "leadtune/rest"


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
  #    p.email = "test@example.com"   
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
  # Your LeadTune username, password, and organization can be specified in the
  # +LEADTUNE_USERNAME+, +LEADTUNE_PASSWORD+, and +LEADTUNE_ORGANIZATION+
  # environment variables. <em>These values take precedence over values read
  # from the configuration file.</em>
  #
  # === Factors Hash
  #
  # When initializing your Prospect, simply include your username, password,
  # and organization along with any other factors you wish to
  # submit. <em>These values take precedence over values read from environment
  # variables, or the configuration file.</em>
  #
  # === Instance Methods
  #
  # You can also set your username, password, and organization by calling the
  # Leadtune::Prospect object's #username=, #password=, and #organization=
  # methods. <em>These values take precedence over values read from
  # environment variables, a configuration file, or the factors hash.</em>
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
  # application's current environment.  If a rack or rails production
  # environment is detected, the Prospect will post prospects to LeadTune's
  # production host.  Otherwise prospects will be posted to LeadTune's sandbox
  # host.  The environment can be overriden via the +APP_ENV+ environment
  # variable, which takes precedence over all other methods.
  #
  #--
  #
  # The host used by the Prospect object can be manually overriden via the
  # LEADTUNE_HOST environment variable, the +host+ configuration file value,
  # or the #leadtune_host method as well.

  class Prospect
    attr_accessor :decision  #:nodoc:

    # Initialize a new Leadtune::Prospect object.  
    #
    # [+config_file+] An optional filename or a file-like object, see
    #                 Authentication above.
    # [+factors+]     A hash of factors with which to initialize the Prospect

    def initialize(*args, &block)
      @factors = {}
      @decision = nil
      @config = {}
      @rest = Rest.new

      load_config_file(args.first)
      load_options(args.extract_options!)

      block.call(self) if block_given?
    end

    # Get a prospect from the LeadTune Appraiser service.
    #
    # Requires that either +prospect_id+ or +prospect_ref+ be set.

    def self.get(options={}, &block)
      new(options, &block).get
    end

    # Post a prospect to the LeadTune Appraiser service.

    def self.post(options={}, &block)
      new(options, &block).post
    end

    # Get a prospect from the LeadTune Appraiser service.
    #
    # Requires that either +prospect_id+ or +prospect_ref+ be set.

    def get
      json = @rest.get(self)
      parse_response(json)
      self
    end

    # Post this prospect to the LeadTune Appraiser service.

    def post
      json = @rest.post(self)
      parse_response(json)
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

    def organization #:nodoc:
      @factors["organization"] ||= 
        ENV["LEADTUNE_ORGANIZATION"] || @config["organization"]
    end
    
    def prospect_id #:nodoc:
      @factors["prospect_id"]
    end

    def prospect_ref #:nodoc:
      @factors["prospect_ref"]
    end

    def leadtune_host=(host)
      @rest.leadtune_host = host
    end

    def leadtune_host
      @rest.leadtune_host
    end

    def username=(username)
      @rest.username = username
    end

    def password=(password)
      @rest.password = password
    end


    private 

    def load_config_file(config_file) #:nodoc:
      find_config_file(config_file)

      if @config_file
        @config = YAML::load(@config_file)
        @rest.config = @config
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

    def load_options(options) #:nodoc:
      @rest.username = options.delete("username") if options.include?("username")
      @rest.password = options.delete("password") if options.include?("password")
      load_factors(options)
    end

    def load_factors(factors) #:nodoc:
      factors.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

    def parse_response(response) #:nodoc:
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
