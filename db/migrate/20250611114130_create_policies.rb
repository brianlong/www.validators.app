class CreatePolicies < ActiveRecord::Migration[6.1]
  def change
    create_table :policies do |t|
      t.string :pubkey, null: false
      t.string :name
      t.string :url
      t.string :mint
      t.string :network
      t.boolean :kind
      t.boolean :strategy
      t.boolean :executable
      t.string :owner
      t.bigint :lamports
      t.string :rent_epoch

      t.timestamps

      t.index :pubkey, unique: true
    end
  end
end
