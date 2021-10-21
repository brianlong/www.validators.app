class AddAuthorizedWithdrawerScoreToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :authorized_withdrawer_score, :integer
  end
end
