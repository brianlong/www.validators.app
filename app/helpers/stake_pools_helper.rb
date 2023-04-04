# frozen_string_literal: true

module StakePoolsHelper
  def stake_pool_logos(stake_pools)
    stake_pools.map do |stake_pool|
      MAINNET_STAKE_POOLS[stake_pool.downcase.to_sym][:small_logo]
    end
  end

  def shuffle_logos
    MAINNET_STAKE_POOLS.map do |pool_key, pool_data|
      [pool_data[:url], pool_data[:large_logo]]
    end.shuffle
  end
end
