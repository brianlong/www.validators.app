class AddEpochUuidToStakeAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_accounts, :batch_uuid, :string
  end
end
