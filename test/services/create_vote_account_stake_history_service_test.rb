# frozen_string_literal: true

require "test_helper"

class CreateVoteAccountStakeHistoryServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"
    @epoch = 1
    @vash_service = CreateVoteAccountStakeHistoryService.new(network: @network, epoch: @epoch)
    @vote_account = create(:vote_account, network: @network, is_active: true)
    @stake_account = create(
      :explorer_stake_account,
      network: @network,
      delegated_vote_account_address: @vote_account.account,
      epoch: @epoch
    )
  end

  test "call creates vote account stake history" do
    @vash_service.call
    vash = VoteAccountStakeHistory.find_by(epoch: @epoch, vote_account: @vote_account, network: @network)

    assert_equal @stake_account.account_balance, vash.account_balance
    assert_equal @stake_account.active_stake, vash.active_stake
    assert_equal @stake_account.credits_observed, vash.credits_observed
    assert_equal @stake_account.deactivating_stake, vash.deactivating_stake
    assert_equal @stake_account.delegated_stake, vash.delegated_stake
    assert_equal @stake_account.rent_exempt_reserve, vash.rent_exempt_reserve
    assert_equal 1, vash.delegating_stake_accounts_count
  end

  test "call creates explorer stake account history stat" do
    @vash_service.call
    esah = ExplorerStakeAccountHistoryStat.find_by(epoch: @epoch, network: @network)

    assert_equal @stake_account.account_balance, esah.account_balance
    assert_equal @stake_account.active_stake, esah.active_stake
    assert_equal @stake_account.credits_observed, esah.credits_observed
    assert_equal @stake_account.deactivating_stake, esah.deactivating_stake
    assert_equal @stake_account.delegated_stake, esah.delegated_stake
    assert_equal @stake_account.rent_exempt_reserve, esah.rent_exempt_reserve
    assert_equal 1, esah.delegating_stake_accounts_count
  end
end
