# frozen_string_literal: true

class CreateVoteAccountHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :vote_account_histories do |t|
      t.references :vote_account, null: false, foreign_key: true
      t.integer :commission
      t.bigint :last_vote
      t.bigint :root_slot
      t.bigint :credits
      t.bigint :activated_stake
      t.string :software_version

      t.timestamps
    end
    add_index :vote_account_histories, %i[vote_account_id created_at]
  end
end
