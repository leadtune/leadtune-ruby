module Leadtune::Prospect::Validations::CommonValidator

  def prospect_id_or_prospect_ref_required(record)
    unless record.prospect_id.present? || record.prospect_ref.present?
      record.errors[:base] << "prospect_id or prospect_ref are required fields"
    end
  end

end
