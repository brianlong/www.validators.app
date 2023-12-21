# frozen_string_literal: true

require "test_helper"

class ExplorerStakeAccountQueryTest < ActiveSupport::TestCase
  setup do
    @network = "mainnet"
    @epoch = create(:epoch_wall_clock, network: @network)
    5.times do |i|
      create(:explorer_stake_account,
        network: @network,
        stake_pubkey: "test_stake_pubkey_#{i}",
        staker: "test_staker_#{i}",
        withdrawer: "test_withdrawer_#{i}",
        delegated_vote_account_address: "test_delegated_vote_account_address_#{i}",
        epoch: @epoch.epoch
      )
    end
  end

  test "ExplorerStakeAccountQueryTest returns correct record by stake pubkey" do
    explorer_stake_account = ExplorerStakeAccountQuery.new(
      stake_pubkey: "test_stake_pubkey_1",
      network: @network
    ).call[:explorer_stake_accounts]

    assert_equal "test_stake_pubkey_1", explorer_stake_account.first.stake_pubkey
    assert_equal 1, explorer_stake_account.count
  end

  test "ExplorerStakeAccountQueryTest returns correct record by staker" do
    explorer_stake_account = ExplorerStakeAccountQuery.new(
      staker: "test_staker_2",
      network: @network
    ).call[:explorer_stake_accounts]

    assert_equal "test_staker_2", explorer_stake_account.first.staker
    assert_equal 1, explorer_stake_account.count
  end

  test "ExplorerStakeAccountQueryTest returns correct record by withdrawer" do
    explorer_stake_account = ExplorerStakeAccountQuery.new(
      withdrawer: "test_withdrawer_3",
      network: @network
    ).call[:explorer_stake_accounts]

    assert_equal "test_withdrawer_3", explorer_stake_account.first.withdrawer
    assert_equal 1, explorer_stake_account.count
  end

  test "ExplorerStakeAccountQueryTest returns correct record by delegated_vote_account_address" do
    explorer_stake_account = ExplorerStakeAccountQuery.new(
      vote_account: "test_delegated_vote_account_address_4",
      network: @network
    ).call[:explorer_stake_accounts]

    assert_equal "test_delegated_vote_account_address_4", explorer_stake_account.first.delegated_vote_account_address
    assert_equal 1, explorer_stake_account.count
  end

  test "ExplorerStakeAccountQueryTest returns multiple correct records given multiple attributes" do
    create(
      :explorer_stake_account,
      network: @network,
      staker: "test_staker_2",
      withdrawer: "test_withdrawer_2",
      delegated_vote_account_address: "test_delegated_vote_account_address_6",
      epoch: @epoch.epoch
    )

    explorer_stake_accounts = ExplorerStakeAccountQuery.new(
      staker: "test_staker_2",
      withdrawer: "test_withdrawer_2",
      network: @network
    ).call[:explorer_stake_accounts]

    assert_equal ["test_delegated_vote_account_address_2", "test_delegated_vote_account_address_6"], explorer_stake_accounts.pluck(:delegated_vote_account_address)
    assert_equal 2, explorer_stake_accounts.count
  end

  test "service returns correct amount of records when limit_count presented" do
    explorer_stake_account = ExplorerStakeAccountQuery.new(
      network: @network,
      limit_count: 3
    ).call[:explorer_stake_accounts]

    assert_equal 3, explorer_stake_account.count
  end
end
