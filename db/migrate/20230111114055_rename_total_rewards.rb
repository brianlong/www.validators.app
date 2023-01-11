# frozen_string_literal: true

class RenameTotalRewards < ActiveRecord::Migration[6.1]
  def change
    rename_column :cluster_stats, :total_rewards, :total_rewards_difference
  end
end
