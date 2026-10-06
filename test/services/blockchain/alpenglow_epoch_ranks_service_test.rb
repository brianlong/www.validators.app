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
          { "votePubkey" => "VoteSmall", "nodePubkey" => "NodeSmall", "activatedStake" => 100, "epochVoteAccount" => true },
          { "votePubkey" => "VoteBigB", "nodePubkey" => "NodeBigB", "activatedStake" => 500, "epochVoteAccount" => true },
          { "votePubkey" => "VoteBigA", "nodePubkey" => "NodeBigA", "activatedStake" => 500, "epochVoteAccount" => true },
          { "votePubkey" => "VoteNoBls", "nodePubkey" => "NodeNoBls", "activatedStake" => 900, "epochVoteAccount" => true },
          { "votePubkey" => "VoteNoStake", "nodePubkey" => "NodeNoStake", "activatedStake" => 0, "epochVoteAccount" => false },
          { "votePubkey" => "VoteDupBls1", "nodePubkey" => "NodeDupBls1", "activatedStake" => 300, "epochVoteAccount" => true },
          { "votePubkey" => "VoteDupBls2", "nodePubkey" => "NodeDupBls2", "activatedStake" => 300, "epochVoteAccount" => true },
          { "votePubkey" => "VoteNotInEpoch", "nodePubkey" => "NodeNotInEpoch", "activatedStake" => 400, "epochVoteAccount" => false }
        ],
        "delinquent" => [
          { "votePubkey" => "VoteDelinquent", "nodePubkey" => "NodeDelinquent", "activatedStake" => 200, "epochVoteAccount" => true }
        ]
      }
      @bls_pubkeys = {
        "VoteSmall" => "5",
        "VoteBigB" => "3",
        "VoteBigA" => "2",
        "VoteNoBls" => nil,
        "VoteDupBls1" => "9",
        "VoteDupBls2" => "9",
        "VoteNotInEpoch" => "7",
        "VoteDelinquent" => "4"
      }
    end

    def rpc_result(result)
      { body: { jsonrpc: "2.0", id: 1, result: result }.to_json }
    end

    def stub_cluster(epoch:)
      stub_request(:post, @rpc_url).with(body: hash_including("method" => "getEpochInfo"))
                                   .to_return(rpc_result("epoch" => epoch, "slotIndex" => 10, "slotsInEpoch" => 54_000))
      stub_request(:post, @rpc_url).with(body: hash_including("method" => "getVoteAccounts"))
                                   .to_return(rpc_result(@vote_accounts))
      stub_request(:post, @rpc_url).with(body: hash_including("method" => "getMultipleAccounts")).to_return do |request|
        keys = JSON.parse(request.body)["params"].first
        value = keys.map do |key|
          bls = @bls_pubkeys[key]
          bls ? { "data" => { "parsed" => { "info" => { "blsPubkeyCompressed" => bls } } } } : nil
        end
        rpc_result("context" => { "slot" => 1 }, "value" => value)
      end
    end

    def call_service
      Blockchain::AlpenglowEpochRanksService.new(network: @network, config_urls: [@rpc_url]).call
    end

    def ranks(epoch)
      AlpenglowEpochRank.for_epoch(@network, epoch)
    end

    test "#call saves provisional ranks for the next epoch from current stake" do
      stub_cluster(epoch: 186)

      call_service

      provisional = ranks(187)
      assert_equal %w[VoteBigA VoteBigB VoteNotInEpoch VoteDupBls1 VoteDupBls2 VoteDelinquent VoteSmall].sort,
                   provisional.map(&:vote_account).sort
      assert_equal (0...7).to_a, provisional.map(&:rank)
      assert(provisional.none?(&:finalized))
      assert_equal %w[NodeBigA 2 500], [provisional.first.validator_identity, provisional.first.bls_pubkey, provisional.first.stake.to_s]
    end

    test "#call does not rebuild provisional ranks that already exist" do
      stub_cluster(epoch: 186)
      call_service
      @vote_accounts["current"].first["activatedStake"] = 10_000

      call_service

      assert_equal 100, ranks(187).find_by(vote_account: "VoteSmall").stake
    end

    test "#call finalizes current epoch ranks keeping only epoch vote accounts and removing duplicates" do
      stub_cluster(epoch: 186)
      call_service
      stub_cluster(epoch: 187)

      call_service

      finalized = ranks(187)
      assert_equal %w[VoteBigA VoteBigB VoteDelinquent VoteSmall], finalized.map(&:vote_account)
      assert_equal [0, 1, 2, 3], finalized.map(&:rank)
      assert(finalized.all?(&:finalized))
      assert_equal 4, AlpenglowEpochRank.finalized.where(network: @network, epoch: 187).count
    end

    test "#call keeps stake values from the previous epoch when finalizing" do
      stub_cluster(epoch: 186)
      call_service
      @vote_accounts["current"].find { |va| va["votePubkey"] == "VoteSmall" }["activatedStake"] = 10_000
      stub_cluster(epoch: 187)

      call_service

      assert_equal %w[VoteBigA VoteBigB VoteDelinquent VoteSmall], ranks(187).map(&:vote_account)
      assert_equal 100, ranks(187).find_by(vote_account: "VoteSmall").stake
    end

    test "#call does not finalize the same epoch twice" do
      stub_cluster(epoch: 186)
      call_service
      stub_cluster(epoch: 187)
      call_service
      created_at = ranks(187).first.created_at

      travel 1.minute do
        call_service
      end

      assert_equal created_at, ranks(187).first.created_at
    end

    test "#call does nothing for the current epoch without provisional ranks" do
      stub_cluster(epoch: 187)

      call_service

      assert_empty ranks(187)
      assert_equal 7, ranks(188).count
    end

    test "#call does nothing when epoch info is unavailable" do
      stub_request(:post, @rpc_url).to_return(rpc_result(nil))

      assert_nil call_service
      assert_equal 0, AlpenglowEpochRank.count
    end
  end
end
