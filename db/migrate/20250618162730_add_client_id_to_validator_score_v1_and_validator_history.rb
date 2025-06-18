class AddClientIdToValidatorScoreV1AndValidatorHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :software_client_id, :integer
    add_column :vote_account_histories, :software_client_id, :integer
    add_column :validator_histories, :software_client_id, :integer
  end
end
