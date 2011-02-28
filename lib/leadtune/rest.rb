# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "curb"
require "json"

module Leadtune
  class Rest #:nodoc:all
    PROSPECTS_PATH = "/prospects"

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

    def delete(post_data)
      @post_data = post_data
      curl = build_curl_easy_object_delete
      curl.http("DELETE")
      parse_response(curl.body_str) unless curl.body_str.empty?
    end


    private

    def build_curl_easy_object(&block) #:nodoc:
      Curl::Easy.new do |curl|
        curl.http_auth_types = [:basic,]
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
       "Accept" => "application/json",
       "X-API-Key" => @config.api_key,}
    end

    def build_curl_easy_object_post #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_post_url
        curl.post_body = @post_data.to_json
        $stderr.puts curl.post_body if curl.verbose?
      end
    end

    def build_curl_easy_object_put #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_put_url
        curl.post_body = @post_data.to_json
      end
    end

    def build_curl_easy_object_delete #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_get_url
      end
    end

    def build_curl_easy_object_get #:nodoc:
      build_curl_easy_object do |curl|
        curl.url = build_get_url
      end
    end

    def build_optional_query_params
      if @config.query_params
        "?" + Leadtune::Util.to_params(@config.query_params)
      else
        ""
      end
    end

    def build_post_url #:nodoc:
      URI.join(@config.leadtune_host, PROSPECTS_PATH, build_optional_query_params).to_s
    end

    def build_get_url #:nodoc:
      params = {:organization => @post_data["organization"],}
      if @post_data["prospect_ref"]
        params.merge!(:prospect_ref => @post_data["prospect_ref"])
      end

      # I would use URI.join, but there's a bug in its implementation in 1.8.6
      build_put_url + "?" + Leadtune::Util.to_params(params)
    end

    def build_put_url #:nodoc:
      path = PROSPECTS_PATH
      path += "/#{@post_data["prospect_id"]}" if @post_data["prospect_id"]
      # I would use URI.join, but there's a bug in its implementation in 1.8.6
      @config.leadtune_host + path
    end

    def parse_response(body)
      @response = body ? JSON::parse(body) : {}
    end

  end
end
