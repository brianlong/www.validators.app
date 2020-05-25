# frozen_string_literal: true

# CreateCollectors
class CreateCollectors < ActiveRecord::Migration[6.0]
  def change
    create_table :collectors do |t|
      t.string :payload_type
      t.integer :payload_version
      t.longtext :payload
      t.string :ip_address
      t.timestamps
    end
  end
end
