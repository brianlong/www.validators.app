class UpdateNetworkActiveStakeIndexInValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    remove_index :validator_score_v1s, column: [:network, :active_stake], name: "index_validator_score_v1s_on_network_and_active_stake", if_exists: true
    add_index :validator_score_v1s, [:network, :active_stake, :commission, :delinquent], name: 'index_for_asns'
  end
end
