class AddAdminWarningToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :admin_warning, :string,  default: nil
  end
end
