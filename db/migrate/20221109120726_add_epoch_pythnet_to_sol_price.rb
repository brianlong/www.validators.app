class AddEpochPythnetToSolPrice < ActiveRecord::Migration[6.1]
  def change
    add_column :sol_prices, :epoch_pythnet, :integer
  end
end
