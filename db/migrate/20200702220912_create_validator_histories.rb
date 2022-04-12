# frozen_string_literal: true

class CreateValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :validator_histories do |t|
      t.string :network
      t.string :batch_uuid
      t.string :account
      t.string :vote_account
      t.decimal :commission, unsigned: true
      t.bigint :last_vote, unsigned: true
      t.bigint :root_block, unsigned: true
      t.bigint :credits, unsigned: true
      t.bigint :active_stake, unsigned: true
      t.boolean :delinquent, default: false

      t.timestamps
    end
    add_index :validator_histories, %i[network batch_uuid]
  end
end
