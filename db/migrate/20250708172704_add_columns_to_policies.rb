class AddColumnsToPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :image, :string
    add_column :policies, :description, :text
    add_column :policies, :additional_metadata, :json
  end
end
