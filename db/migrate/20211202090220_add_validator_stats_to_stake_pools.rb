class AddValidatorStatsToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :average_delinquent, :float
    add_column :stake_pools, :average_skipped_slots, :float
  end
end
