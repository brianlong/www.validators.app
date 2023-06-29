# frozen_string_literal: true

require "test_helper"

module StakePools
  class CalculateAverageStatsTest < ActiveSupport::TestCase
    setup do
      @validator = create(
        :validator,
        account: "account_test",
        created_at: 10.days.ago
      )
      @validator_2 = create(
        :validator,
        account: "account_test_2",
        created_at: 10.days.ago
      )

      @stake_pool = create(
        :stake_pool,
        network: "testnet"
      )
      @stake_pool_2 = create(
        :stake_pool,
        network: "testnet"
      )

      create(
        :validator_score_v1,
        validator: @validator,
        skipped_slot_history: [2, 5],
        delinquent: true,
        network: "testnet",
        commission: 5
      )
      create(
        :validator_score_v1,
        validator: @validator_2,
        commission: 10,
        network: "testnet"
      )

      create(:stake_account,
        validator: @validator_2,
        stake_pool: @stake_pool,
        delegated_vote_account_address: "vote_acc_2",
        active_stake: 722_555_666
      )
    end

    test "generates average stake pool attributes" do
      create(
        :stake_account,
        stake_pool: @stake_pool,
        delegated_vote_account_address: "vote_acc",
        validator: @validator,
        active_stake: 2_555_666_777
      )

      create(
        :validator_history,
        network: "testnet",
        delinquent: true,
        created_at: DateTime.now - 3.days,
        account: "account_test",
        validator: @validator
      )
      create(
        :validator_history,
        network: "testnet",
        delinquent: true,
        created_at: DateTime.now - 3.days,
        account: "account_test_2",
        validator: @validator_2
      )

      StakePools::CalculateAverageStats.new(@stake_pool).call

      assert_equal 3, @stake_pool.average_uptime
      assert_equal 10, @stake_pool.average_lifetime
      assert_equal 2.55, @stake_pool.average_skipped_slots
      assert_equal 7, @stake_pool.average_score
      assert_equal 6.1, @stake_pool.average_validators_commission
    end

    test "#delinquent_count is 1 when \
          stake accounts belong to stake pool and \
          has delinquent score with minimum stake" do
      create(
        :stake_account,
        stake_pool: @stake_pool,
        delegated_vote_account_address: "vote_acc",
        validator: @validator,
        active_stake: 2_555_666_777
      )

      StakePools::CalculateAverageStats.new(@stake_pool).call

      assert_equal 1, @stake_pool.delinquent_count
    end

    test "#delinquent_count is 0 when \
          stake accounts belong to DIFFERENT stake pool and \
          has delinquent score with minimum stake" do
      create(
        :stake_account,
        stake_pool: @stake_pool_2,
        delegated_vote_account_address: "vote_acc",
        validator: @validator,
        active_stake: 2_555_666_777
      )

      StakePools::CalculateAverageStats.new(@stake_pool).call

      assert_equal 0, @stake_pool.delinquent_count
    end

    test "#delinquent_count is 0 when has delinquent score WITHOUT minimum stake" do
      create(
        :stake_account,
        stake_pool: @stake_pool,
        delegated_vote_account_address: "vote_acc",
        validator: @validator,
        active_stake: 555_666_777
      )

      StakePools::CalculateAverageStats.new(@stake_pool).call

      assert_equal 0, @stake_pool.delinquent_count
    end
  end
end
