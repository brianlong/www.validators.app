class AddSlotFieldsToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :slot_sent, :bigint
    add_column :ping_things, :slot_landed, :bigint
  end
end
