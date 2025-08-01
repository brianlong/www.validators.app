class AddTokenHoldersToPolicy < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :token_holders, :text
  end
end
