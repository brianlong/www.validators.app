# frozen_string_literal: true

require "test_helper"

module StakePools
  class CalculateAverageStatsTest < ActiveSupport::TestCase

    test "update_stake_pools" do
      validator = create(
        :validator,
        account: "account_test",
        created_at: 10.days.ago
      )
      validator_2 = create(
        :validator,
        account: "account_test_2",
        created_at: 10.days.ago
      )

      stake_pool = create(
        :stake_pool,
        network: "testnet"
      )

      create(
        :validator_history,
        network: "testnet",
        delinquent: "true",
        created_at: DateTime.now - 3.days,
        account: "account_test"
      )
      create(
        :validator_history,
        network: "testnet",
        delinquent: "true",
        created_at: DateTime.now - 3.days,
        account: "account_test_2"
      )

      create(
        :validator_score_v1,
        validator: validator,
        skipped_slot_history: [2, 5],
        delinquent: true,
        network: "testnet",
        commission: 5
      )
      create(
        :validator_score_v1,
        validator: validator_2,
        commission: 10
      )

      create(
        :vote_account,
        network: "testnet",
        account: "vote_acc"
      )
      create(
        :vote_account,
        network: "testnet",
        account: "vote_acc_2"
      )

      create(
        :stake_account,
        stake_pool: stake_pool,
        delegated_vote_account_address: "vote_acc",
        validator: validator,
        active_stake: 422_555_666
      )
      create(:stake_account,
        validator: validator_2,
        stake_pool: stake_pool,
        delegated_vote_account_address: "vote_acc_2",
        active_stake: 722_555_666
      )

      StakePools::CalculateAverageStats.new(stake_pool).call

      assert_equal 3, stake_pool.average_uptime
      assert_equal 10, stake_pool.average_lifetime
      assert_equal 2.55, stake_pool.average_skipped_slots
      assert_equal 7, stake_pool.average_score
      assert_equal 8.15, stake_pool.average_validators_commission
      assert_equal 1, stake_pool.delinquent_count
    end
  end
end
