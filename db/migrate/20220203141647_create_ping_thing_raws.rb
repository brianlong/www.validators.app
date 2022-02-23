class CreatePingThingRaws < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_raws do |t|
      t.string :token
      t.text :raw_data

      t.timestamps
    end
  end
end
