class AddIndexToValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_histories, [:account, :delinquent, :created_at],
      name: :delinquent_by_account_index
    add_index :validator_histories, [:account, :created_at, :active_stake],
      name: :acceptable_stake_by_account_index
  end
end
