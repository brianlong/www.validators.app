class AddCollaborationToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :jito_collaboration, :boolean, default: false
  end
end
