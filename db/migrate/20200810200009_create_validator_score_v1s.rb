# frozen_string_literal: true

class CreateValidatorScoreV1s < ActiveRecord::Migration[6.0]
  def change
    create_table :validator_score_v1s do |t|
      t.references :validator
      t.text :root_distance_history
      t.integer :root_distance_score
      t.text :vote_distance_history
      t.integer :vote_distance_score
      t.text :skipped_slot_history
      t.integer :skipped_slot_score
      t.text :skipped_after_history
      t.integer :skipped_after_score
      t.string :software_version
      t.integer :software_version_score
      t.bigint :active_stake
      t.integer :active_stake_score
      t.integer :data_center_concentration
      t.integer :data_center_score
      t.timestamps
    end
  end
end
