class AddIsMutedToValidatorIps < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_ips, :is_muted, :boolean, default: false
  end
end
