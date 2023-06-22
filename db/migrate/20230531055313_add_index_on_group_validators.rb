class AddIndexOnGroupValidators < ActiveRecord::Migration[6.1]
  def change
    add_index :group_validators, :group_id
    add_index :group_validators, :validator_id
  end
end
