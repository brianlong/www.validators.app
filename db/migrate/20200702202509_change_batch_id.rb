# frozen_string_literal: true

# Change :batch_id to :batch_uuid throughout the app
class ChangeBatchId < ActiveRecord::Migration[6.0]
  def change
    # ping_time_stats
    remove_index :ping_time_stats, :batch_id
    rename_column :ping_time_stats, :batch_id, :batch_uuid
    add_index :ping_time_stats, :batch_uuid

    # ping_times
    remove_index :ping_times, :batch_id
    rename_column :ping_times, :batch_id, :batch_uuid
    add_index :ping_times, :batch_uuid

    # reports
    rename_column :reports, :batch_id, :batch_uuid
    add_index :reports, :batch_uuid

    # validator_block_histories
    remove_index :validator_block_histories, :batch_id
    rename_column :validator_block_histories, :batch_id, :batch_uuid
    add_index :validator_block_histories, :batch_uuid

    # validator_block_history_stats
    remove_index :validator_block_history_stats, :batch_id
    rename_column :validator_block_history_stats, :batch_id, :batch_uuid
    add_index :validator_block_history_stats, :batch_uuid
  end
end
