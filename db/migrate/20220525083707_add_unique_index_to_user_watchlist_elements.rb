class AddUniqueIndexToUserWatchlistElements < ActiveRecord::Migration[6.1]
  def change
    add_index :user_watchlist_elements, [:user_id, :validator_id], unique: true
  end
end
