# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "json"

module Leadtune
  class Rest #:nodoc:all

    attr_reader :response

    def initialize(config)
      @config = config
      @post_data = nil
      @response = {}
    end

    def get(post_data)
      @post_data = post_data
      curl = build_curl_easy_object_get
      curl.http("GET")
      parse_response(curl.body_str)
    end

    def post(post_data)
      @post_data = post_data
      curl = build_curl_easy_object_post
      curl.http("POST")
      parse_response(curl.body_str)
    end

    def put(post_data)
      @post_data = post_data
      curl = build_curl_easy_object_put
      curl.http("PUT")
      parse_response(curl.body_str)
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
          raise LeadtuneError.new(curl.response_code, curl.body_str)
        end
        # curl.verbose = true
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
        curl.post_body = @post_data.to_json
        $stderr.puts curl.post_body if curl.verbose?
      end
    end

    def build_curl_easy_object_put #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_put_url
        curl.put_data = @post_data.to_json
        $stderr.puts curl.post_body if curl.verbose?
      end
    end

    def build_curl_easy_object_get #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_get_url
      end
    end

    def build_get_url #:nodoc:
      params = {:organization => @post_data["organization"],}
      if @post_data["prospect_ref"]
        params.merge!(:prospect_ref => @post_data["prospect_ref"]) 
      end

      URI.join(build_put_url, "?" + params.to_params).to_s
    end

    def build_put_url #:nodoc:
      path = "/prospects"
      path += "/#{@post_data["prospect_id"]}" if @post_data["prospect_id"]
      URI.join(@config.leadtune_host, path).to_s
    end

    def parse_response(body)
      @response = body ? JSON::parse(body) : {}
    end

  end
end
