# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

module Blockchain
  class AlpenglowEpochRanksServiceTest < ActiveSupport::TestCase
    setup do
      @network = "alpenglow-community"
      @rpc_url = "https://alpenglow.example.com/token"
      @vote_accounts = {
        "current" => [
          { "votePubkey" => "VoteSmall", "nodePubkey" => "NodeSmall", "activatedStake" => 100 },
          { "votePubkey" => "VoteBigB", "nodePubkey" => "NodeBigB", "activatedStake" => 500 },
          { "votePubkey" => "VoteBigA", "nodePubkey" => "NodeBigA", "activatedStake" => 500 },
          { "votePubkey" => "VoteNoBls", "nodePubkey" => "NodeNoBls", "activatedStake" => 900 },
          { "votePubkey" => "VoteNoStake", "nodePubkey" => "NodeNoStake", "activatedStake" => 0 },
          { "votePubkey" => "VoteDupBls1", "nodePubkey" => "NodeDupBls1", "activatedStake" => 300 },
          { "votePubkey" => "VoteDupBls2", "nodePubkey" => "NodeDupBls2", "activatedStake" => 300 }
        ],
        "delinquent" => [
          { "votePubkey" => "VoteDelinquent", "nodePubkey" => "NodeDelinquent", "activatedStake" => 200 }
        ]
      }
      @bls_pubkeys = {
        "VoteSmall" => "5",
        "VoteBigB" => "3",
        "VoteBigA" => "2",
        "VoteNoBls" => nil,
        "VoteDupBls1" => "9",
        "VoteDupBls2" => "9",
        "VoteDelinquent" => "4"
      }
    end

    def stub_rpc(method, result)
      stub_request(:post, @rpc_url)
        .with(body: hash_including("method" => method))
        .to_return(body: { jsonrpc: "2.0", id: 1, result: result }.to_json)
    end

    def stub_cluster(epoch: 186)
      stub_rpc("getEpochInfo", { "epoch" => epoch, "slotIndex" => 10, "slotsInEpoch" => 54_000 })
      stub_rpc("getVoteAccounts", @vote_accounts)
      stub_request(:post, @rpc_url)
        .with(body: hash_including("method" => "getMultipleAccounts"))
        .to_return do |request|
          keys = JSON.parse(request.body)["params"].first
          value = keys.map do |key|
            bls = @bls_pubkeys[key]
            bls ? { "data" => { "parsed" => { "info" => { "blsPubkeyCompressed" => bls } } } } : nil
          end
          { body: { jsonrpc: "2.0", id: 1, result: { "context" => { "slot" => 1 }, "value" => value } }.to_json }
        end
    end

    def call_service
      Blockchain::AlpenglowEpochRanksService.new(network: @network, config_urls: [@rpc_url]).call
    end

    test "#call saves ranks for the next epoch ordered by stake and bls pubkey" do
      stub_cluster

      assert_equal 4, call_service

      ranks = AlpenglowEpochRank.for_epoch(@network, 187)
      assert_equal %w[VoteBigA VoteBigB VoteDelinquent VoteSmall], ranks.map(&:vote_account)
      assert_equal [0, 1, 2, 3], ranks.map(&:rank)
      assert_equal %w[NodeBigA 2 500], [ranks.first.validator_identity, ranks.first.bls_pubkey, ranks.first.stake.to_s]
    end

    test "#call skips accounts without stake, without bls pubkey or with duplicated bls pubkey" do
      stub_cluster
      call_service

      accounts = AlpenglowEpochRank.where(network: @network).pluck(:vote_account)
      refute_includes accounts, "VoteNoStake"
      refute_includes accounts, "VoteNoBls"
      refute_includes accounts, "VoteDupBls1"
      refute_includes accounts, "VoteDupBls2"
    end

    test "#call does nothing when ranks for the next epoch already exist" do
      stub_cluster
      call_service

      assert_nil call_service
      assert_equal 4, AlpenglowEpochRank.count
    end

    test "#call does nothing when epoch info is unavailable" do
      stub_request(:post, @rpc_url).to_return(body: { jsonrpc: "2.0", id: 1, result: nil }.to_json)

      assert_nil call_service
      assert_equal 0, AlpenglowEpochRank.count
    end
  end
end
