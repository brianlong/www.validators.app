# frozen_string_literal: true

class AddDelinquentCountToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :delinquent_count, :integer
  end
end
