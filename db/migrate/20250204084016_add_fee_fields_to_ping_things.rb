class AddFeeFieldsToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :priority_fee_micro_lamports, :float
    add_column :ping_things, :priority_fee_percentile, :integer
    add_column :ping_things, :pinger_region, :string
  end
end
