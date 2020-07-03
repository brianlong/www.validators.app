# frozen_string_literal: true

class FixNetworkBatch < ActiveRecord::Migration[6.0]
  def change
    # batches
    add_column :batches, 'network', :string, before: :uuid
    ActiveRecord::Base.connection.execute(
      "update batches set network = 'testnet' where network is null"
    )
    remove_index :batches, :uuid
    add_index :batches, %i[network uuid]

    # epoch_histories
    add_column :epoch_histories, 'network', :string, before: :batch_uuid
    ActiveRecord::Base.connection.execute(
      "update epoch_histories set network = 'testnet' where network is null"
    )
    remove_index :epoch_histories, :batch_uuid
    add_index :epoch_histories, %i[network batch_uuid]

    # ping_time_stats
    add_column :ping_time_stats, 'network', :string, before: :batch_uuid
    ActiveRecord::Base.connection.execute(
      "update ping_time_stats set network = 'testnet' where network is null"
    )
    remove_index :ping_time_stats, :batch_uuid
    add_index :ping_time_stats, %i[network batch_uuid]

    # ping_times
    remove_index :ping_times, :batch_uuid
    add_index :ping_times, %i[network batch_uuid]

    # reports
    remove_index :reports, :batch_uuid
    add_index :reports, %i[network batch_uuid]

    # validator_block_histories
    add_column :validator_block_histories, 'network', :string, before: :epoch
    ActiveRecord::Base.connection.execute(
      "update validator_block_histories set network = 'testnet' where network is null"
    )
    remove_index :validator_block_histories, :batch_uuid
    add_index :validator_block_histories, %i[network batch_uuid]

    # validator_block_history_stats
    add_column :validator_block_history_stats, 'network', :string, before: :batch_uuid
    ActiveRecord::Base.connection.execute(
      "update validator_block_history_stats set network = 'testnet' where network is null"
    )
    remove_index :validator_block_history_stats, :batch_uuid
    add_index :validator_block_history_stats, %i[network batch_uuid]

    # vote_account_histories
    add_column :vote_account_histories, 'network', :string
    ActiveRecord::Base.connection.execute(
      "update vote_account_histories set network = 'testnet' where network is null"
    )
    add_column :vote_account_histories, 'batch_uuid', :string
    add_index :vote_account_histories, %i[network batch_uuid]
  end
end
