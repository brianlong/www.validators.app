# frozen_string_literal: true

class AddNetworkTotalActiveStakeToClusterStat < ActiveRecord::Migration[6.1]
  def change
    add_column :cluster_stats, :network_total_active_stake, :bigint
  end
end
