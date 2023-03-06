class RenameJitoCollaborationOnValidators < ActiveRecord::Migration[6.1]
  def change
    rename_column :validators, :jito_collaboration, :jito
  end
end
