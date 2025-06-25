class ConvertSoftwareClientToString < ActiveRecord::Migration[6.1]
  def change
    change_column :validator_score_v1s, :software_client, :string, default: nil
  end
end
