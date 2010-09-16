# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

require "json"

require "seller/response/appraisals"

module Leadtune
  class Seller

    # Simplify the processing of LeadTune duplicate checking and appraisal
    # responses.
    # 
    # For details about the LeadTune Seller API, see:
    # http://leadtune.com/api/seller
    #
    # Inspect your lead's appraisal:
    #
    #  require "rubygems"
    #  require "leadtune/seller"
    #
    #  seller = Leadtune::Seller.new
    #  ... see docs for Leadtune::Seller
    #  response = seller.post
    #  response.decision_id     # => "4c8f9e1eb34601dd40b3c030"
    #  response.email_hash      # => "823776525776c8f23a87176c59d25759da7a52c4"
    #  response.browser_family  # => "Firefox"
    #  response.browser_version # => "3.6.3"
    #  response.appraisals.non_duplicates # => [{"value" => 1, "target_buyer" => "TB-LOL"}]
    #  response.appraisals.duplicates     # => [{"value" => 0, "target_buyer" => "AcmeU"}]

    class Response
      
      def initialize(json_response) #:notnew:
        @json = JSON::parse(json_response)
        wrap_helpers_around_appraisals
      end

      # The unique +decision_id+ for this Response.
      def decision_id
        @json["decision"]["decision_id"]
      end

      # The appraisals for this Response.
      #
      # The Array returned has been extended to include two methods,
      # +duplicates+ and +non_duplicates+.  Each returns the appraisals of the
      # target_buyers for whom this lead is or is not a known duplicate.
      def appraisals
        @json["decision"]["appraisals"]
      end

      # An array of factors confirmed in the Response.  
      #
      # Each recognized factor sent to LeadTune will be returned in this
      # response.  Additionally, each recognized factor is available via a
      # method of the same name on the Response object, e.g. if a call to
      # #factors includes a factor named +browser_family+, then the Response
      # object will have a method named #browser_family.
      def factors
        @json.keys - ["decision",]
      end

      def method_missing(sym, *args, &block) #:nodoc:
        @json.include?(sym.to_s) ? @json[sym.to_s] : super
      end

      def respond_to?(sym) #:nodoc:
        super || @json.include?(sym.to_s)
      end

      
      private

      def wrap_helpers_around_appraisals
        appraisals = @json["decision"]["appraisals"] || [] rescue []
        appraisals = Appraisals.new(appraisals)
        @json.merge!("decision" => {"appraisals" => appraisals,})
      end

    end

  end
end
