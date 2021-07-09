class CreateCommissionHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :commission_histories do |t|
      t.references :validator, null: false, foreign_key: true
      t.float :commission_before
      t.float :commission_after
      t.string :batch_uuid

      t.timestamps
    end
  end
end
