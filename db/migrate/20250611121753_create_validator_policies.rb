class CreateValidatorPolicies < ActiveRecord::Migration[6.1]
  def change
    create_table :validator_policies do |t|
      t.references :policy, null: false, foreign_key: true
      t.references :validator, null: false, foreign_key: true

      t.timestamps
    end
  end
end
