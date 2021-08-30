class AddNetworkToCommissionHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :commission_histories, :network, :string
    add_index :commission_histories, [:network],
              name: :index_commission_histories_on_network
    add_index :commission_histories, [:network, :validator_id],
              name: :index_commission_histories_on_network_and_validator_id
  end
end
