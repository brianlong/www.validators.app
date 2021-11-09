class CreateValidatorScoreV2s < ActiveRecord::Migration[6.0]
  def change
    create_table :validator_score_v2s do |t|
      t.references :validator
      t.integer :total_score

      t.text :root_distance_history
      t.integer :root_distance_score

      t.text :vote_distance_history
      t.integer :vote_distance_score

      t.text :skipped_slot_history
      t.integer :skipped_slot_score
      t.text :skipped_slot_moving_average_history

      t.text :skipped_vote_history
      t.integer :skipped_vote_score
      t.text :skipped_vote_percent_moving_average_history

      t.string :software_version
      t.integer :software_version_score

      t.decimal :stake_concentration, precision: 10, scale: 3
      t.integer :stake_concentration_score

      t.decimal :data_center_concentration, precision: 10, scale: 3
      t.integer :data_center_concentration_score

      t.integer :authorized_withdrawer_score
      t.integer :published_information_score
      t.integer :security_report_score

      t.bigint :active_stake, unsigned: true
      t.integer :commission
      t.boolean :delinquent
      t.string :ip_address
      t.string :network
      t.string :data_center_key
      t.string :data_center_host
      t.timestamps

      t.index [:network, :data_center_key], name: 'index_validator_score_v2s_on_network_and_data_center_key'
    end
  end
end
