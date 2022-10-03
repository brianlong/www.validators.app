class CreateIpable < ActiveRecord::Migration[6.1]
  def change
    create_table :ipables do |t|
      t.bigint :ip_id
      t.bigint :ipable_id
      t.string :ipable_type

      t.timestamps
    end
  end
end
