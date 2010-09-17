require "active_model"

module Leadtune
  class Prospect
    module Validations #:nodoc:all

      def self.included(base)
        base.class_eval do
          include ActiveModel::Validations

          validates_presence_of :username, :password, :organization
          validates_presence_of :event, :decision, 
                                :if => lambda {"POST" == @method.to_s.upcase}
          validate :email_or_email_hash_required, 
                   :validate_decision,
                   :prospect_id_or_prospect_ref_required

          def validate_decision
            return if @decision.nil?
            return unless decision_required?

            if @decision.empty?
              errors.add(:decision, "must not be empty")
            end

            unless @decision.is_a?(Hash)
              errors.add(:decision, "must be a Hash")
            end

            unless @decision.keys.include?("target_buyers")
              errors.add(:decision, "required key \"target_buyers\" not found")
            end

            unless target_buyers_is_enumerable?
              errors.add(:decision, "\"target_buyers\" must be Enumerable")
            end
          end

          def email_or_email_hash_required
            return unless email_or_email_hash_required?

            unless ["email_hash", "email"].any? {|f| @factors[f].present?}
              errors.add(:base, "email or email_hash are required fields")
            end
          end

          def prospect_id_or_prospect_ref_required
            return unless prospect_id_or_prospect_ref_required?

            unless ["prospect_id", "prospect_ref"].any? {|f| @factors[f].present?}
              errors.add(:base, "prospect_id or prospect_ref are required fields")
            end
          end


          private

          def prospect_id_or_prospect_ref_required?
            ["DELETE", "GET", "PUT",].include?(@method.to_s.upcase)
          end
          def post_or_put?
            ["POST", "PUT",].include?(@method.to_s.upcase)
          end
          alias_method :email_or_email_hash_required?, :post_or_put?
          alias_method :decision_required?, :post_or_put?

          def target_buyers_is_enumerable?
            @decision["target_buyers"] && 
              @decision["target_buyers"].is_a?(Enumerable)
          end

        end
      end

    end
  end
end
