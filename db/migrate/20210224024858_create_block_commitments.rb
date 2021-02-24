class CreateBlockCommitments < ActiveRecord::Migration[6.0]
  def change
    create_table :block_commitments do |t|
      t.string :network
      # t.int :epoch
      t.bigint :slot
      t.text :commitment
      t.bigint :total_stake
      t.timestamps
    end
    # add_index :block_commitments, [:network, :epoch, :slot]
    add_index :block_commitments, [:network, :slot], unique: true
  end
end
