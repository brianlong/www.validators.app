class AddIndexesToCommissionHistories < ActiveRecord::Migration[6.1]
  def change
    remove_index :commission_histories, :network, name: "index_commission_histories_on_network"
    add_index :commission_histories, [:network, :created_at, :validator_id], name: "index_commission_histories_on_validators"
    add_index :commission_histories, :epoch
  end
end
