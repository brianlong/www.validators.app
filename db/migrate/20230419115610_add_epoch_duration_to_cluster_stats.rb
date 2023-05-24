# frozen_string_literal: true

class AddEpochDurationToClusterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :cluster_stats, :epoch_duration, :float
  end
end
