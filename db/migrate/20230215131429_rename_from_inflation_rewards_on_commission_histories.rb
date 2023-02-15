class RenameFromInflationRewardsOnCommissionHistories < ActiveRecord::Migration[6.1]
  def change
    rename_column :commission_histories, :from_inflation_rewards, :source_from_rewards
  end
end
