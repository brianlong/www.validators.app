class CreateDataCenterStats < ActiveRecord::Migration[6.1]
  def change
    create_table :data_center_stats do |t|
      t.references :data_center, null: false, foreign_key: true
      t.integer :gossip_nodes_count
      t.integer :validators_count
      t.string :network

      t.timestamps
    end
  end
end
