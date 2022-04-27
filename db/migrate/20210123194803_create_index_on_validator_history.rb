class CreateIndexOnValidatorHistory < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_histories, [:network, :account, :id]
  end
end
