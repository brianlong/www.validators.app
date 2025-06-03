class RenameSoftwareKindInValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    rename_column :validator_score_v1s, :software_kind, :software_client
  end
end
