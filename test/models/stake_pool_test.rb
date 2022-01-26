require "test_helper"

class StakePoolTest < ActiveSupport::TestCase
  setup do
    @stake_pool = create(:stake_pool,
                         network: "testnet",
                         name: "TestName",
                         authority: "authority")

    @validator1 = create(:validator, :with_score, name: "Validator", account: "Account")
    @validator2 = create(:validator, :with_score, name: "Validator", account: "Account2")

    [5_000_000_000_000, 4_000_000_000_000].each do |stake_value|
      create(:stake_account,
             network: "testnet",
             validator: @validator1,
             stake_pool: @stake_pool,
             active_stake: stake_value,
             delegated_stake: stake_value,
             staker: "staker1")
    end

    [2_000_000_000_000, 1_000_000_000_000].each do |stake_value|
      create(:stake_account,
             network: "testnet",
             validator: @validator2,
             stake_pool: @stake_pool,
             active_stake: stake_value,
             delegated_stake: stake_value,
             staker: "staker1")
    end
  end

  test 'validators_count' do
    assert_equal 2, @stake_pool.reload.validators_count
  end

  test 'total_stake' do
    assert_equal 12_000_000_000_000, @stake_pool.reload.total_stake
  end

  test 'average_stake' do
    assert_equal 6_000_000_000_000, @stake_pool.reload.average_stake
  end

  test 'average_stake if no validators assigned' do
    StakeAccount.all.each do |sa|
      sa.update validator_id: nil
    end
    assert_equal 0, @stake_pool.reload.validators_count
    assert_equal 0, @stake_pool.reload.average_stake
  end
end
