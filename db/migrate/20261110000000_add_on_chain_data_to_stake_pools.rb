# frozen_string_literal: true

class AddOnChainDataToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :pool_address, :string
    add_column :stake_pools, :total_lamports, :bigint, unsigned: true
    add_column :stake_pools, :pool_token_supply, :bigint, unsigned: true
    add_column :stake_pools, :next_manager_fee, :float
    add_column :stake_pools, :next_withdrawal_fee, :float
  end
end
