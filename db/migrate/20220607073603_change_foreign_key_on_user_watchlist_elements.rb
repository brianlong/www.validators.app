class ChangeForeignKeyOnUserWatchlistElements < ActiveRecord::Migration[6.1]
  def change
    # remove_foreign_key :user_watchlist_elements, :user
    add_foreign_key :user_watchlist_elements, :users, on_delete: :cascade

    remove_foreign_key :user_watchlist_elements, :validators
    add_foreign_key :user_watchlist_elements, :validators, on_delete: :cascade
  end
end
