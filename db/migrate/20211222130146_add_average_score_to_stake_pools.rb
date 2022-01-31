class AddAverageScoreToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :average_score, :float
  end
end
