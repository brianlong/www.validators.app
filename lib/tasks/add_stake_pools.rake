# frozen_string_literal: true

def update_stake_pools(stake_pools)
  stake_pools.each do |key, data|
    StakePool.find_or_initialize_by(
      name: data[:name],
      network: data[:network]
    ).update(
      ticker: data[:ticker],
      authority: data[:authority],
    )
  end
end

def update_stake_pools_fees(stake_pools)
  stake_pools.each do |key, data|
    stake_pool = StakePool.find_by(
      name: data[:name],
      network: data[:network]
    )
    stake_pool.update!(
      manager_fee: data[:manager_fee],
      withdrawal_fee: data[:withdrawal_fee],
      deposit_fee: data[:deposit_fee],
    )
  end
end

# To manually run this task type:
# RAILS_ENV=stage bundle exec rake add_stake_pools:mainnet
# RAILS_ENV=production bundle exec rake add_stake_pools:mainnet
namespace :add_stake_pools do
  task mainnet: :environment do
    update_stake_pools(MAINNET_STAKE_POOLS)
  end

  task testnet: :environment do
    update_stake_pools(TESTNET_STAKE_POOLS)
  end

  task pythnet: :environment do
    update_stake_pools(PYTHNET_STAKE_POOLS)
  end
end

# Run the following task if @manager_fees changes
# RAILS_ENV=stage bundle exec rake update_fees_in_stake_pools:mainnet
# RAILS_ENV=production bundle exec rake update_fees_in_stake_pools:mainnet
namespace :update_fees_in_stake_pools do
  task mainnet: :environment do
    update_stake_pools_fees(MAINNET_STAKE_POOLS)
  end

  task testnet: :environment do
    update_stake_pools_fees(TESTNET_STAKE_POOLS)
  end

  task pythnet: :environment do
    update_stake_pools_fees(PYTHNET_STAKE_POOLS)
  end
end
