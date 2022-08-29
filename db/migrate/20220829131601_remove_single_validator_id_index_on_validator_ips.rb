class RemoveSingleValidatorIdIndexOnValidatorIps < ActiveRecord::Migration[6.1]
  def change
    remove_index :validator_ips, :validator_id
  end
end
