class AddIsActiveToValidatorIps < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_ips, :is_active, :boolean, default: false
    add_index :validator_ips, :is_active
  end
end
