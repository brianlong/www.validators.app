class AddIndexOnActiveStakeToValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_histories, :active_stake
  end
end
