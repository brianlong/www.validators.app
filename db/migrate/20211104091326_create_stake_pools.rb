class CreateStakePools < ActiveRecord::Migration[6.1]
  def change
    create_table :stake_pools do |t|
      t.string :name
      t.string :authority

      t.timestamps
    end
  end
end
