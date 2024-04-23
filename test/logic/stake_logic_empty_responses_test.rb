# frozen_string_literal: true

require 'test_helper'

class StakeLogicEmptyResponsesTest < ActiveSupport::TestCase
  include StakeLogic

  # overwrite cli_request to return empty response
  def cli_request(cli_method, rpc_urls)
    {}
  end
  # overwrite solana_client_request to return empty response
  def solana_client_request(clusters, method, params: [], use_token: false)
    {}
  end

  setup do
    create(:batch)
    @initial_payload = {
      # config_urls: Rails.application.credentials.solana[:testnet_urls],
      config_urls: [
        @testnet_url
      ],
      network: 'testnet'
    }
  end

  test "get_stake_accounts \
        when getting no response \
        should raise error" do
    authority = 'H2qwtMNNFh6euD3ym4HLgpkbNY6vMdf5aX5bazkU4y8b'
    create(:stake_pool, authority: authority, network: 'testnet')

    p = Pipeline.new(200, @initial_payload)
                .then(&get_last_batch)
                .then(&get_stake_accounts)

    assert_nil p[:payload][:stake_accounts]
    assert_equal "No results from `solana stakes`", p.errors.message
    assert_equal NoResultsFromSolana, p.errors.class
    assert_equal 500, p.code
  end

  test "get_rewards_from_stake_pools \
       when response is empty \
       should raise error" do
    stake_pool = create(:stake_pool)
    validator = create(:validator)
    validator2 = create(:validator)
    score = create(:validator_score_v1, validator: validator)
    score2 = create(:validator_score_v1, validator: validator2)
    score.update_columns(total_score: 10)
    score2.update_columns(total_score: 9)
    create(:stake_account, validator: validator, stake_pool: stake_pool)
    create(:stake_account, validator: validator2, stake_pool: stake_pool)

    p = Pipeline.new(200, @initial_payload)
              .then(&get_rewards_from_stake_pools)

    assert_equal "No results from `get_inflation_reward`", p.errors.message
    assert_equal NoResultsFromSolana, p.errors.class
    assert_equal 500, p.code
  end
end
