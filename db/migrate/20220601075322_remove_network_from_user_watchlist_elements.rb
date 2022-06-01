class RemoveNetworkFromUserWatchlistElements < ActiveRecord::Migration[6.1]
  def change
    remove_column :user_watchlist_elements, :network, :string
  end
end
