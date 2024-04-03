class AddIndexToValidatorIps < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_ips, [:is_active, :address]
  end
end
