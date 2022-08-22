class AddIndexOnValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_histories, [:network, :batch_uuid, :account]
  end
end
