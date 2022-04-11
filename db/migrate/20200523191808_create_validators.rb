# frozen_string_literal: true

# CreateValidators
class CreateValidators < ActiveRecord::Migration[6.1]
  def change
    create_table :validators do |t|
      t.string :network
      t.string :account
      t.string :name
      t.string :keybase_id
      t.string :www_url
      t.timestamps
    end
    add_index :validators, %i[network account], unique: true
  end
end
