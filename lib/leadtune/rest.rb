require "json"

module Leadtune
  class Rest

    def initialize(config)
      @config = config
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


    private

    def build_curl_easy_object(&block) #:nodoc:
      Curl::Easy.new do |curl|
        curl.http_auth_types = [:basic,]
        curl.username = @config.username
        curl.password = @config.password
        curl.timeout = @config.timeout
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
        curl.url = URI.join(@config.leadtune_host, "/prospects").to_s
        curl.post_body = @prospect.post_data.to_json
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
      if @prospect.prospect_ref
        params.merge!(:prospect_ref => @prospect.prospect_ref) 
      end

      URI.join(@config.leadtune_host, path, "?" + params.to_params).to_s
    end

  end
end
