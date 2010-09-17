class Leadtune::Prospect::Validations::DeleteValidator < ActiveModel::Validator
  include CommonValidator

  def validate(record)
    prospect_id_or_prospect_ref_required(record)
  end

end
