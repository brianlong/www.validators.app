class AddEpochUuidToStakeAccountHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_account_histories, :batch_uuid, :string
  end
end
