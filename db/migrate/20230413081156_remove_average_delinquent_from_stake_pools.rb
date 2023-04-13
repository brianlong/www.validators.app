# frozen_string_literal: true

class RemoveAverageDelinquentFromStakePools < ActiveRecord::Migration[6.1]
  def change
    remove_column :stake_pools, :average_delinquent, :float
  end
end
