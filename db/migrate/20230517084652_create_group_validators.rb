class CreateGroupValidators < ActiveRecord::Migration[6.1]
  def change
    create_table :group_validators do |t|
      t.integer :group_id
      t.integer :validator_id

      t.timestamps
    end
  end
end
