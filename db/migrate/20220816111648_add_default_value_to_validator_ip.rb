class AddDefaultValueToValidatorIp < ActiveRecord::Migration[6.1]
  def change
    change_column_null :validator_ips, :validator_id, true
  end
end
