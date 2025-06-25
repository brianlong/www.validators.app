class AddSoftwareClientToValidatorHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_histories, :software_client, :string
    add_column :vote_account_histories, :software_client, :string
  end
end
