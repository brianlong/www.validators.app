class AddTraitsAutonomousSystemNumberIndexToDataCenters < ActiveRecord::Migration[6.1]
  def change
    add_index :data_centers, :traits_autonomous_system_number
  end
end
