class AddEpochInfoToCommissionHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :commission_histories, :epoch, :integer
    add_column :commission_histories, :epoch_completion, :float
  end
end
