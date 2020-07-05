# frozen_string_literal: true

class CreateFeedZones < ActiveRecord::Migration[6.0]
  def change
    create_table :feed_zones do |t|
      t.string 'network'
      t.string 'batch_uuid'
      t.datetime 'batch_created_at'
      t.integer 'payload_version'
      t.text 'payload', size: :long

      t.timestamps
    end
    add_index :feed_zones, %i[network batch_uuid], unique: true
    add_index :feed_zones, %i[network batch_created_at]
  end
end
