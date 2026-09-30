class CreateAlpenglowValidatorEpochStats < ActiveRecord::Migration[6.1]
  def change
    create_table :alpenglow_validator_epoch_stats do |t|
      t.string :network, null: false
      t.integer :epoch, null: false
      t.bigint :vote_account_id, null: false
      t.bigint :validator_id, null: false

      t.integer :notar_reward_slots, default: 0, null: false
      t.integer :notar_votes, default: 0, null: false

      t.integer :fast_finalized_slots, default: 0, null: false
      t.integer :fast_final_signatures, default: 0, null: false
      t.integer :slow_finalized_slots, default: 0, null: false
      t.integer :slow_final_signatures, default: 0, null: false
      t.integer :slow_notar_signatures, default: 0, null: false

      t.integer :skip_votes, default: 0, null: false
      t.integer :divergent_skip_votes, default: 0, null: false

      t.integer :leader_slots, default: 0, null: false
      t.integer :leader_slots_with_final_cert, default: 0, null: false
      t.integer :leader_fast_finalized, default: 0, null: false
      t.integer :leader_slow_finalized, default: 0, null: false
      t.bigint :leader_final_lag_sum, default: 0, null: false
      t.string :last_block_user_agent

      t.timestamps
    end

    add_index :alpenglow_validator_epoch_stats, %i[vote_account_id epoch], unique: true,
              name: "index_alpenglow_val_epoch_stats_on_vote_account_id_epoch"
    add_index :alpenglow_validator_epoch_stats, %i[validator_id epoch]
    add_index :alpenglow_validator_epoch_stats, %i[network epoch]
  end
end
