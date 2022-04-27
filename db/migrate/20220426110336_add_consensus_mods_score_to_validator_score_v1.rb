class AddConsensusModsScoreToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :consensus_mods_score, :integer, default: 0
  end
end
