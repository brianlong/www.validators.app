class UpdateIndexInValidators < ActiveRecord::Migration[6.1]
  def change
    remove_index :validators, column: [:network, :is_active, :is_destroyed], name: "index_validators_on_network_and_is_active_and_is_destroyed", if_exists: true

    add_index :validators, [:network, :is_active, :is_destroyed, :is_rpc], name: "index_validators_on_network_is_active_is_destroyed_is_rpc"
  end
end
