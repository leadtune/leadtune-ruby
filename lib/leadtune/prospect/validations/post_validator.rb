class Leadtune::Prospect::Validations::PostValidator < ActiveModel::Validator

  def validate(record)
    email_or_email_hash_required(record)
    validate_decision(record.decision)
  end


  private

  def email_or_email_hash_required(record)
    unless record.email_hash.present? || record.email.present?
      record.errors[:base] << "email or email_hash are required fields"
    end
  end

  def validate_decision(record)
    decision = record.decision

    if decision.empty?
      record.errors[:decision] << "must not be empty"
    end

    unless decision.is_a?(Hash)
      record.errors[:decision] << "must be a Hash"
    end

    unless decision.keys.include?("target_buyers")
      errors[:decision] << "required key \"target_buyers\" not found"
    end

    unless target_buyers_is_enumerable?(decision)
      errors[:decision] << "\"target_buyers\" must be Enumerable"
    end
  end
  
  def target_buyers_is_enumerable?(decision)
    decision["target_buyers"] && 
      decision["target_buyers"].is_a?(Enumerable)
  end

end
