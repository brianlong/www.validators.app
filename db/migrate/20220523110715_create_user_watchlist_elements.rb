class CreateUserWatchlistElements < ActiveRecord::Migration[6.1]
  def change
    create_table :user_watchlist_elements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :validator, null: false, foreign_key: true
      t.string :network

      t.timestamps
    end
  end
end
