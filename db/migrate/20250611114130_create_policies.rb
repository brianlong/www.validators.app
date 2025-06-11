class CreatePolicies < ActiveRecord::Migration[6.1]
  def change
    create_table :policies do |t|
      t.string :name
      t.string :url
      t.string :mint
      t.boolean :kind
      t.boolean :strategy
      t.boolean :executable
      t.string :owner
      t.bigint :lamports
      t.bigint :rent_epoch

      t.timestamps
    end
  end
end
