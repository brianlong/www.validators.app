# frozen_string_literal: true

class ChangeEpochCreditsToBigintInValidatorHistories < ActiveRecord::Migration[6.1]
  def up
    change_column :validator_histories, :epoch_credits, :bigint, unsigned: true
  end

  def down
    change_column :validator_histories, :epoch_credits, :integer, unsigned: true
  end
end
