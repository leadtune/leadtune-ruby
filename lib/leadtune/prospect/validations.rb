require "active_model"

module Leadtune
  class Prospect
    module Validations #:nodoc:all

      def self.included(base)
        base.class_eval do
          include ActiveModel::Validations

          validates_presence_of :username, :password, :organization
          validates :instance_validations
        end
      end

      def instance_validations
        case @http_method_for_validations
        when "delete"
          validates_with DeleteValidator 
        when "get"
          validates_with GetValidator 
        when "post"
          validates_with PostValidator 
        when "put"
          validates_with PutValidator 
        else
          raise NotImplementedError.new("Don't know how to validate for method: #{@http_method_for_validation.inspect}")
        end
      end

      alias_method :run_validations_with_method!, :run_validations!
      alias_method :run_validations!, :run_validations_without_method!

      def run_validations_without_method!
        raise NotImplementedError.new("Use run_validations_for_x! Where x is one of DELETE, GET, POST, or PUT.")
      end

      def valid?
        raise NotImplementedError.new("Use valid_for_x? Where x in one of DELETE, GET, POST, or PUT.")
      end

      ["delete", "get", "post", "put",].each do |method|
        define_method("run_validations_for_#{method}!") do
          @http_method_for_validations = method
          run_validations_with_method!
        end

        define_method("invalid_for_#{method}?") do
          !send("valid_for_#{method}?")
        end

        define_method("valid_for_#{method}?") do
          send("run_validations_for_#{method}!")
        end

        define_method("#{method}?") do
          @http_method_for_validations == method
        end
      end

    end
  end
end
