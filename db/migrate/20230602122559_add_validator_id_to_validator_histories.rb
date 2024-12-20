# frozen_string_literal: true

class AddValidatorIdToValidatorHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_histories, :validator_id, :integer, null: true, foreign_key: true, default: nil
  end
end
