# frozen_string_literal: true

require "test_helper"

class GatherExplorerStakeAccountsServiceTest < ActiveSupport::TestCase
  setup do
    @testnet_url = 'https://api.testnet.solana.com'
    @mainnet_url = 'https://api.mainnet-beta.solana.com'
    @json_data = file_fixture("stake_accounts.json").read
    @network = "mainnet"
    @epoch_wall_clock = create(:epoch_wall_clock, network: @network, epoch: 333)
  end

  test "gather_explorer_stake_accounts saves correct records" do
    SolanaCliService.stub(:request, @json_data, ['stakes', @mainnet_url]) do
      GatherExplorerStakeAccountsService.new(
        network: @network,
        config_urls: [@mainnet_url],
        demo: false,
        current_epoch: 123
      ).call

      assert_equal 10, ExplorerStakeAccount.count
      assert_equal [123], ExplorerStakeAccount.all.map(&:epoch).uniq
    end
  end

  test "gather_explorer_stake_accounts does not save records in demo mode" do
    SolanaCliService.stub(:request, @json_data, ['stakes', @mainnet_url]) do
      GatherExplorerStakeAccountsService.new(
        network: @network,
        config_urls: [@mainnet_url],
        demo: true,
        current_epoch: 123
      ).call

      refute ExplorerStakeAccount.any?
    end
  end

  test "gather_explorer_stake_accounts gets correct current_epoch if given nil" do
    SolanaCliService.stub(:request, @json_data, ['stakes', @mainnet_url]) do
      GatherExplorerStakeAccountsService.new(
        network: @network,
        config_urls: [@mainnet_url],
        demo: false
      ).call

      assert_equal 333, ExplorerStakeAccount.last.epoch
    end
  end
end
