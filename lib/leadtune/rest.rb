class Leadtune::Rest

  attr_accessor :environment, :username, :password, :timeout #:nodoc:

  def initialize
    @config = {}
    @prospect = nil
  end

  def get(prospect)
    @prospect = prospect
    curl = build_curl_easy_object_get
    curl.http("GET")
    curl.body_str ? JSON::parse(curl.body_str) : {}
  end

  def post(prospect)
    @prospect = prospect
    curl = build_curl_easy_object_post
    curl.http("POST")
    curl.body_str ? JSON::parse(curl.body_str) : {}
  end

  def config=(config)
    @config = config
  end


  private

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

  def timeout #:nodoc:
    @timeout ||= 
      (ENV["LEADTUNE_TIMEOUT"] || @config["timeout"] || DEFAULT_TIMEOUT).to_i
  end

  def username #:nodoc:
    @username ||= ENV["LEADTUNE_USERNAME"] || @config["username"]
  end

  def password #:nodoc:
    @password ||= ENV["LEADTUNE_PASSWORD"] || @config["password"]
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
      curl.post_body = @prospect.factors.merge(:decision => @prospect.decision).to_json
    end
  end

  def build_curl_easy_object_get #:nodoc:
    build_curl_easy_object do |curl|
      curl.url = build_get_url
    end
  end

  def build_get_url #:nodoc:
    path = "/prospects"
    path += "/#{@prospect.prospect_id}" if @prospect.prospect_id
    params = {:organization => @prospect.organization,}
    params.merge!(:prospect_ref => @prospect.prospect_ref) if @prospect.prospect_ref

    URI.join(leadtune_host, path, "?" + params.to_params).to_s
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

end
