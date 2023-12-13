# frozen_string_literal: true

require "test_helper"

class ExplorerStakeAccountsControllerTest < ActionDispatch::IntegrationTest

  setup do
    epoch_wall_clock = create(:epoch_wall_clock)
    @explorer_stake_accounts = (1000..1050).map do |stake|
      create(:explorer_stake_account, delegated_stake: stake, epoch: epoch_wall_clock.epoch)
    end
  end

  test "should get index" do
    get explorer_stake_accounts_url
    assert_response :success
  end

  test 'assigns explorer_stake_accounts variable' do
    get explorer_stake_accounts_url(network: 'testnet')
    assert_equal @explorer_stake_accounts.sort_by(&:delegated_stake).reverse.first(20),
      @controller.view_assigns['explorer_stake_accounts']
  end

  test 'assigns explorer_stake_accounts variable when filters presented' do
    get explorer_stake_accounts_url(
      network: 'testnet', staker: 'staker', stake_pubkey: 'stake_pubkey',
      delegated_vote_account_address: 'vote_account_address'
    )
    assert_equal @explorer_stake_accounts.sort_by(&:delegated_stake).reverse.first(25),
      @controller.view_assigns['explorer_stake_accounts']
  end
end
