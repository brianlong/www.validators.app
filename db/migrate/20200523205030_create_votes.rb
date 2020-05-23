# frozen_string_literal: true

class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.references :vote_account, null: false, foreign_key: true
      t.integer :commission
      t.bigint :last_vote
      t.bigint :root_slot
      t.bigint :credits
      t.bigint :activated_stake
      t.string :software_version

      t.timestamps
    end
    add_index :votes, %i[vote_account_id created_at]
  end
end
