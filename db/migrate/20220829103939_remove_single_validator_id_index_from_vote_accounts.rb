class RemoveSingleValidatorIdIndexFromVoteAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_index :vote_accounts, :validator_id
  end
end
