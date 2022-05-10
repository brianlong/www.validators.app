# frozen_string_literal: true

require 'test_helper'

class VoteAccountDetailsServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"
    @validator_identity = "validatoridentity"
    @authorized_withdrawer = "authorizedwithdrawer"
    @testnet_url = "https://api.testnet.solana.com"

    @json_response = {
      validatorIdentity: @validator_identity,
      authorizedWithdrawer: @authorized_withdrawer
    }.to_json

    @val = create(:validator, network: @network)
    @score = create(:validator_score_v1, network: @network, validator: @val)

    @va1 = create(
      :vote_account,
      validator: @val,
      network: @network,
      account: "acc1"
    )
  end

  test "VoteAccountDetailsService updates identity and withdrawer" do
    SolanaCliService.stub(:request, @json_response, ["vote-account", @testnet_url]) do
      Gatherers::VoteAccountDetailsService.new(network: @network, config_urls: [@testnet_url]).call

      assert_equal @va1.reload.validator_identity, @validator_identity
      assert_equal @va1.reload.authorized_withdrawer, @authorized_withdrawer
      assert_equal 0, @score.reload.authorized_withdrawer_score
    end
  end

  test "VoteAccountDetailsService sets correct score" do
    @json_response = {
      validatorIdentity: "equal_token",
      authorizedWithdrawer: "equal_token"
    }.to_json

    SolanaCliService.stub(:request, @json_response, ["vote-account", @testnet_url]) do
      Gatherers::VoteAccountDetailsService.new(network: @network, config_urls: [@testnet_url]).call

      assert_equal -2, @score.reload.authorized_withdrawer_score
    end
  end
end
