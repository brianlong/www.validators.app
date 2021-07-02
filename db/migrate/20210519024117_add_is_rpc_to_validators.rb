class AddIsRpcToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :is_rpc, :boolean, default: false
  end
end
