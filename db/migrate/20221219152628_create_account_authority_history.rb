# frozen_string_literal: true

class CreateAccountAuthorityHistory < ActiveRecord::Migration[6.1]
  def change
    create_table :account_authority_histories do |t|
      t.string :authorized_withdrawer_before
      t.string :authorized_withdrawer_after
      t.text :authorized_voters_before
      t.text :authorized_voters_after
      t.references :vote_account, null: false, foreign_key: true
      t.string :network

      t.timestamps
    end
  end
end
