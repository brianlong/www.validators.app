class AddFieldsToValidatorIps < ActiveRecord::Migration[6.1]
  def change
    add_reference :validator_ips, :data_center, null: true, foreign_key: true
    add_column :validator_ips, :is_overridden, :boolean, default: false
    add_column :validator_ips, :traits_ip_address, :string
    add_column :validator_ips, :traits_network, :string
  end
end
