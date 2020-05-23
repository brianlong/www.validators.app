# frozen_string_literal: true

# CreateValidatorIps
class CreateValidatorIps < ActiveRecord::Migration[6.0]
  def change
    create_table :validator_ips do |t|
      t.references :validator, null: false, foreign_key: true
      t.integer :version, default: 4
      t.string :address
      # Insert MaxMind fields here
      t.datetime :max_mind_updated_at
      t.timestamps
    end
    add_index :validator_ips, %i[validator_id version address], unique: true
  end
end
