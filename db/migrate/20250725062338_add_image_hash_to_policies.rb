class AddImageHashToPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :image_hash, :string
    rename_column :policies, :image, :image_url
  end
end
