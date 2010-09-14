require "active_model"

module Leadtune
  class Seller
    module Validations

      def self.included(base)
        base.class_eval do
          include ActiveModel::Validations

          validates_presence_of :event, :organization, :decision, 
                                :username, :password
          validate :email_or_email_hash_required, :validate_decision

          def validate_decision
            return unless @decision

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
            unless ["email_hash", "email"].any? {|f| @factors[f].present?}
              errors.add(:base, "email or email_hash are required fields")
            end
          end


          private
          
          def target_buyers_is_enumerable?
            @decision["target_buyers"] && 
              @decision["target_buyers"].is_a?(Enumerable)
          end

        end
      end

    end
  end
end
