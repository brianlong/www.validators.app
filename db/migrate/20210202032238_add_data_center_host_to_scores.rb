class AddDataCenterHostToScores < ActiveRecord::Migration[6.0]
  def change
    add_column :validator_score_v1s, :data_center_host, :string
  end
end
