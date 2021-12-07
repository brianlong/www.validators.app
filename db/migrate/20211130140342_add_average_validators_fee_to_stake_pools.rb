class AddAverageValidatorsFeeToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :average_validators_commission, :float
  end
end
