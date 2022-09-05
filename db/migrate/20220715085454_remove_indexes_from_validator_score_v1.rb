class RemoveIndexesFromValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    remove_index "validator_score_v1s", column: [:network], name: "index_validator_score_v1s_on_network"
    remove_index "validator_score_v1s", column: [:total_score], name: "index_validator_score_v1s_on_total_score"
    remove_index "validator_score_v1s", column: [:validator_id], name: "index_validator_score_v1s_on_validator_id"
  end
end
