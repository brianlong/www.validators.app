# frozen_string_literal: true

class AddStakePoolListToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :stake_pool_list, :text, null: true
  end
end
