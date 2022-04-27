# frozen_string_literal: true

class AddScoresToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :security_report_url, :string
    add_column :validator_score_v1s, :published_information_score, :integer
    add_column :validator_score_v1s, :security_report_score, :integer
  end
end
