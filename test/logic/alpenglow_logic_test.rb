# frozen_string_literal: true

require 'test_helper'

class AlpenglowLogicTest < ActiveSupport::TestCase
  include AlpenglowLogic

  def setup
    @mainnet_initial_payload = {
      config_urls: ['https://api.mainnet-beta.solana.com'],
      network: 'mainnet'
    }
  end

  test 'alpenglow_vote_credits_get merges credits from AlpenglowVoteRewardsService' do
    payload = @mainnet_initial_payload.merge(
      epoch: 1064, epoch_slot_index: 100, epoch_start_slot: 1_000,
      vote_accounts: { 'node1' => { 'credits_current' => 1 } }, total_vote_accounts_stake: 10
    )
    service = Minitest::Mock.new
    service.expect :call, { 'node1' => { 'credits_current' => 5, 'max_credits_current' => 7 } },
                   [payload[:vote_accounts], 10]

    p = AlpenglowVoteRewardsService.stub(:new, ->(**) { service }) do
      Pipeline.new(200, payload).then(&alpenglow_vote_credits_get)
    end

    assert_equal 200, p.code
    assert_equal({ 'node1' => { 'credits_current' => 5, 'max_credits_current' => 7 } }, p.payload[:vote_accounts])
    service.verify
  end

  test 'alpenglow_vote_credits_get keeps payload when rewards cannot be fetched' do
    payload = @mainnet_initial_payload.merge(vote_accounts: { 'node1' => { 'credits_current' => 1 } })
    failing_service = Object.new
    def failing_service.call(*)
      raise 'rpc down'
    end

    p = AlpenglowVoteRewardsService.stub(:new, ->(**) { failing_service }) do
      Pipeline.new(200, payload).then(&alpenglow_vote_credits_get)
    end

    assert_equal 200, p.code
    assert_equal payload[:vote_accounts], p.payload[:vote_accounts]
  end
end
