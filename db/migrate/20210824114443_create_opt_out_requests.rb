class CreateOptOutRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :opt_out_requests do |t|
      t.integer :request_type
      t.json   :meta_data

      t.string :name_encrypted
      t.string :street_address_encrypted
      t.string :city_encrypted
      t.string :postal_code_encrypted
      t.string :state_encrypted

      # These can be removed if you are using Vault
      t.string :name_encrypted_iv
      t.string :street_address_encrypted_iv
      t.string :city_encrypted_iv
      t.string :postal_code_encrypted_iv
      t.string :state_encrypted_iv

      t.timestamps
    end
  end
end
