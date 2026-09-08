class AddCreatedAtIndexToValidatorBlockHistories < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_block_histories, :created_at
  end
end
