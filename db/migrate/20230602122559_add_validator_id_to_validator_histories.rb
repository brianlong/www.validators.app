# frozen_string_literal: true

class AddValidatorIdToValidatorHistories < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :validator_histories, :validator_id, :integer, null: true, foreign_key: true
    execute <<~SQL
      ALTER TABLE validator_histories
      ADD INDEX index_validator_histories_on_validator_id(validator_id),
      ALGORITHM=DEFAULT,
      LOCK=NONE;
    SQL
  end
end
