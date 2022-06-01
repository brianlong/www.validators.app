class CreateUserWatchlistElements < ActiveRecord::Migration[6.1]
  def change
    create_table :user_watchlist_elements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :validator, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :validator_id], unique: true
    end
  end
end
