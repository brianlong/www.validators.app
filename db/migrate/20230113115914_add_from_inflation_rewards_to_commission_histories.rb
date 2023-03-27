class AddFromInflationRewardsToCommissionHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :commission_histories, :from_inflation_rewards, :boolean, default: false
  end
end
