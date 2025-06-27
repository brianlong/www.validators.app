class CreatePolicyIdentities < ActiveRecord::Migration[6.1]
  def change
    create_table :policy_identities do |t|
      t.references :policy, null: false, foreign_key: true
      t.references :validator, foreign_key: true
      t.string :account

      t.timestamps
    end
  end
end
