# frozen_string_literal: true

class AddValidatorIdIndexToValidatorHistories < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      ALTER TABLE validator_histories
      ADD INDEX index_validator_histories_on_validator_id(validator_id),
      ALGORITHM=DEFAULT,
      LOCK=NONE;
    SQL
  end

  def down
    remove_index :validator_histories, name: "index_validator_histories_on_validator_id"
  end
end
