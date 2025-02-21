class AddSoftwareKindToValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :software_kind, :integer, default: 0
  end
end
