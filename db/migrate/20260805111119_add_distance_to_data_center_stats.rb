class AddDistanceToDataCenterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :data_center_stats, :root_distance, :json
    add_column :data_center_stats, :vote_distance, :json
  end
end
