class AddJitoCommissionToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :jito_commission, :integer
  end
end
