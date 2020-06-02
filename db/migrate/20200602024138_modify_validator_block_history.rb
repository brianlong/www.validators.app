# frozen_string_literal: true

class ModifyValidatorBlockHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :validator_block_histories, :batch_id, :string
    add_index :validator_block_histories, :batch_id
  end
end
