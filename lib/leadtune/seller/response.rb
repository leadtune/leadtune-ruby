require "json"

module Leadtune
  class Seller

    class Response
      
      def initialize(curb_response)
        @json = JSON::parse(curb_response.body)
      end

      def appraisals
        @json["decision"]["appraisals"]
      end

      def method_missing(sym, *args, &block)
        @json.include?(sym.to_s) ? @json[sym.to_s] : super
      end

      def respond_to?(sym)
        super || @json.include?(sym.to_s)
      end

    end

  end
end
