class AddSlotIndexCurrent < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_account_histories, :slot_index_current, :integer
  end
end
