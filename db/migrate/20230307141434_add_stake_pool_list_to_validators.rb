# frozen_string_literal: true

class AddStakePoolListToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :stake_pools_list, :text, null: true
  end
end
