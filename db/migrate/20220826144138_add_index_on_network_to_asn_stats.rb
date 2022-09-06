class AddIndexOnNetworkToAsnStats < ActiveRecord::Migration[6.1]
  def change
    add_index :asn_stats, :network
  end
end
