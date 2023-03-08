require "test_helper"

class StakeAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @stake_account = build(:stake_account)
  end

  test "#stake_pool_valid" do
    refute @stake_account.stake_pool_valid

    stake_pool = build(:stake_pool, name: "StakePoolTest")
    @stake_account.stake_pool = stake_pool

    assert_equal @stake_account.stake_pool_valid, stake_pool

    stake_pool = build(:stake_pool, name: "BlazeStake")
    @stake_account.active_stake = 1_225
    @stake_account.stake_pool = stake_pool

    refute @stake_account.stake_pool_valid
  end
end
