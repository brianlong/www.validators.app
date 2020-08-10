# frozen_string_literal: true

class CreateValidatorScoreV1s < ActiveRecord::Migration[6.0]
  def change
    create_table :validator_score_v1s do |t|
      t.references :validator

      t.timestamps
    end
  end
end
