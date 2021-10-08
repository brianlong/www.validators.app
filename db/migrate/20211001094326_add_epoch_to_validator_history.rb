class AddEpochToValidatorHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_histories, :epoch, :integer
  end
end
