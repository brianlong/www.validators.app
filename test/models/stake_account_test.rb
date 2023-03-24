require "test_helper"

class StakeAccountTest < ActiveSupport::TestCase
  setup do
    @stake_pool = build(:stake_pool)
    @minimum_stake = StakeAccountQuery::MINIMUM_STAKE
  end

  test "#stake_pool_valid returns stake pool if meets conditions" do
    stake_account = build(:stake_account, stake_pool: @stake_pool, active_stake: @minimum_stake)
    assert_equal stake_account.stake_pool, @stake_pool
    assert_equal stake_account.stake_pool_valid, @stake_pool

    stake_account = build(:stake_account, stake_pool: @stake_pool, active_stake: (@minimum_stake - 1))
    refute stake_account.stake_pool_valid, "too little stake"
  end
end
