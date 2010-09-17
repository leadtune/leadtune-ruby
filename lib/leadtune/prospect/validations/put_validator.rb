class Leadtune::Prospect::Validations::PutValidator < ActiveModel::Validator
  include CommonValidator

  def validate(record)
    prospect_id_or_prospect_ref_required(record)
  end

end
