class RemoveBatchUuidIndexFromValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    remove_index :validator_histories, [:network, :batch_uuid], name: "index_validator_histories_on_network_and_batch_uuid"
  end
end
