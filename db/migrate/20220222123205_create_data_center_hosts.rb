class CreateDataCenterHosts < ActiveRecord::Migration[6.1]
  def change
    create_table :data_center_hosts do |t|
      t.references :data_center
      t.string :host

      t.timestamps
    end
  end
end
