class RemoveValidatorIdIndexFromValidatorBlockHistories < ActiveRecord::Migration[6.1]
  def change
    remove_index :validator_block_histories, :validator_id
  end
end
