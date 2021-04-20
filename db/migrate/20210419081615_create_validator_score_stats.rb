class CreateValidatorScoreStats < ActiveRecord::Migration[6.1]
  def change
    create_table :validator_score_stats do |t|
      t.string :network
      t.float :root_distance_average
      t.integer :root_distance_median
      t.float :vote_distance_average
      t.integer :vote_distance_median

      t.timestamps
    end
  end
end
