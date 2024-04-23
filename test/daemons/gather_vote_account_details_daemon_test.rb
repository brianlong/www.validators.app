# frozen_string_literal: true

require 'test_helper'

class GatherVoteAccountDetailsDaemonTest < ActiveSupport::TestCase
  setup do
    @v = create(:validator, network: 'testnet')
    create(:validator_score_v1, validator: @v, network: 'testnet')
    create(
      :vote_account,
      account: 'vote_account_1',
      network: 'testnet',
      validator: @v
    )

    @testnet_url = 'https://api.testnet.solana.com'
  end

  test 'validator_identity and authorized_withdrawer should be updated' do
    json_data = {
      "validatorIdentity":"abcdef",
      "authorizedWithdrawer":"abcdef"
    }.to_json
    SolanaCliService.stub(:request, json_data, ['vote-account vote_account_1', @testnet_url]) do
      Gatherers::VoteAccountDetailsService.new(
        network: 'testnet',
        config_urls: [@testnet_url]
      ).call

      assert_equal 'abcdef', @v.vote_accounts.last.authorized_withdrawer
      assert_equal 'abcdef', @v.vote_accounts.last.validator_identity
    end
  end

  test 'score \
        when validator_identity and authorized_withdrawer are not equal \
        should have authorized_withdrawer_score eq 0' do
    json_data = {
      "validatorIdentity":"abcdef",
      "authorizedWithdrawer":"abcdefghi"
    }.to_json
    SolanaCliService.stub(:request, json_data, ['vote-account vote_account_1', @testnet_url]) do
      Gatherers::VoteAccountDetailsService.new(
        network: 'testnet',
        config_urls: [@testnet_url]
      ).call

      @v.score.reload
      assert_equal 0, @v.score.authorized_withdrawer_score
    end
  end

  test 'score \
        when validator_identity and authorized_withdrawer are equal \
        should have authorized_withdrawer_score eq -2' do
    json_data = {
      "validatorIdentity":"abcdef",
      "authorizedWithdrawer":"abcdef"
    }.to_json
    SolanaCliService.stub(:request, json_data, ['vote-account vote_account_1', @testnet_url]) do
      Gatherers::VoteAccountDetailsService.new(
        network: 'testnet',
        config_urls: [@testnet_url]
      ).call

      @v.score.reload
      assert_equal -2, @v.score.authorized_withdrawer_score
    end
  end
end
