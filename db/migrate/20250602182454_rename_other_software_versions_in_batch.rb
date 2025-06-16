class RenameOtherSoftwareVersionsInBatch < ActiveRecord::Migration[6.1]
  def change
    rename_column :batches, :other_software_versions, :software_versions
  end
end
