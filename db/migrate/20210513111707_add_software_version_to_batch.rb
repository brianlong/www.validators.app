class AddSoftwareVersionToBatch < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :software_version, :string
  end
end
