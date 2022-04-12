# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports do |t|
      t.string :network
      t.string :name
      t.longtext :payload
      t.string :batch_id

      t.timestamps
    end
    add_index :reports, %i[network name created_at]
  end
end
