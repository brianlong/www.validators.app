class AddActiveValidatorsStakeToDataCenterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :data_center_stats, :active_validators_stake, :float, default: 0
  end
end
