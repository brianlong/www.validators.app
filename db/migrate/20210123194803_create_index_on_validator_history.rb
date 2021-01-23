class CreateIndexOnValidatorHistory < ActiveRecord::Migration[6.0]
  def change
    add_index :validator_histories, [:network, :account, :id]
  end
end
