require "active_model"

module Leadtune
  class Seller
    module Validations

      def self.included(base)
        base.class_eval do
          include ActiveModel::Validations

          validates_presence_of :event, :organization, :decision, 
                                :username, :password
          validate :email_or_email_hash_required


          def email_or_email_hash_required
            unless ["email_hash", "email"].any? {|f| @factors[f].present?}
              errors.add(:base, "email or email_hash are required fields")
            end
          end

        end
      end

    end
  end
end
