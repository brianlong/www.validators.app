class RemoveDataCenterHostFromValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    remove_column :validator_score_v1s, :data_center_host, :string
  end
end
