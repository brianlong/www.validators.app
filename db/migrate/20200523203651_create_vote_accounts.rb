# frozen_string_literal: true

# CreateVoteAccounts
class CreateVoteAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :vote_accounts do |t|
      t.references :validator, null: false, foreign_key: true
      t.string :account

      t.timestamps
    end
    add_index :vote_accounts, %i[validator_id account], unique: true
    add_index :vote_accounts, %i[account created_at]
  end
end
