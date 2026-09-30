class CreateAlpenglowEpochRanks < ActiveRecord::Migration[6.1]
  def change
    create_table :alpenglow_epoch_ranks do |t|
      t.string :network, null: false
      t.integer :epoch, null: false
      t.integer :rank, null: false
      t.string :vote_account, null: false
      t.string :validator_identity, null: false
      t.string :bls_pubkey, null: false
      t.bigint :stake, null: false

      t.timestamps
    end

    add_index :alpenglow_epoch_ranks, %i[network epoch rank], unique: true
    add_index :alpenglow_epoch_ranks, %i[network epoch vote_account], unique: true,
              name: "index_alpenglow_epoch_ranks_on_network_epoch_vote_account"
  end
end
