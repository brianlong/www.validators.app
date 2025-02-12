class AddFeeFieldsToPingThingArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_archives, :priority_fee_micro_lamports, :float
    add_column :ping_thing_archives, :priority_fee_percentile, :integer
    add_column :ping_thing_archives, :pinger_region, :string
  end
end
