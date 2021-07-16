class AddVoteAccountIndexToValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_histories, [:network, :vote_account]
  end
end
