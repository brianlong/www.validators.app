class AddFieldsToBatch < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :root_distance_all_average, :float
    add_column :batches, :root_distance_all_median, :integer
    add_column :batches, :vote_distance_all_average, :float
    add_column :batches, :vote_distance_all_median, :integer
  end
end
