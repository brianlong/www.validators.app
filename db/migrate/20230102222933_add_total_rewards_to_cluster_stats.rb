# frozen_string_literal: true

class AddTotalRewardsToClusterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :cluster_stats, :total_rewards, :bigint
  end
end
