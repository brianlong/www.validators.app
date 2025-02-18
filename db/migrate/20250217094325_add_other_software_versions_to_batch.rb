class AddOtherSoftwareVersionsToBatch < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :other_software_versions, :text
  end
end
