# frozen_string_literal: true

class ReplaceFinalizedWithStatusOnAlpenglowEpochRanks < ActiveRecord::Migration[6.1]
  def up
    add_column :alpenglow_epoch_ranks, :status, :integer, limit: 1, default: 0, null: false
    execute "UPDATE alpenglow_epoch_ranks SET status = 1 WHERE finalized = TRUE"
    remove_column :alpenglow_epoch_ranks, :finalized
  end

  def down
    add_column :alpenglow_epoch_ranks, :finalized, :boolean, default: false, null: false
    execute "UPDATE alpenglow_epoch_ranks SET finalized = TRUE WHERE status <> 0"
    remove_column :alpenglow_epoch_ranks, :status
  end
end
