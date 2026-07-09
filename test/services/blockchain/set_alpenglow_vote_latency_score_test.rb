# frozen_string_literal: true

require "test_helper"

module Blockchain
  class SetAlpenglowVoteLatencyScoreTest < ActiveSupport::TestCase

    setup do
      @network = "alpenglow-community"
      @validator1 = create(:validator, :with_score, network: @network, account: "node1")
      @validator2 = create(:validator, :with_score, network: @network, account: "node2")
      @validator3 = create(:validator, :with_score, network: @network, account: "node3")

      @vote_accounts_response = [
        { "nodePubkey" => "node1", "lastVote" => 100 },
        { "nodePubkey" => "node2", "lastVote" => 98 },
        { "nodePubkey" => "node3", "lastVote" => 95 }
      ]
    end

    test "#call saves vote latency history for each validator" do
      service = SetAlpenglowVoteLatencyScore.new(@network)
      service.stub(:fetch_vote_accounts, @vote_accounts_response) do
        service.call
      end

      assert_equal [0.0], @validator1.score.reload.vote_latency_history
      assert_equal [2.0], @validator2.score.reload.vote_latency_history
      assert_equal [5.0], @validator3.score.reload.vote_latency_history
    end

    test "#call appends to existing vote latency history" do
      @validator1.score.update(vote_latency_history: [1.0, 2.0])

      service = SetAlpenglowVoteLatencyScore.new(@network)
      service.stub(:fetch_vote_accounts, @vote_accounts_response) do
        service.call
      end

      assert_equal [1.0, 2.0, 0.0], @validator1.score.reload.vote_latency_history
    end

    test "#call respects MAX_HISTORY limit" do
      @validator1.score.update(vote_latency_history: (0..ValidatorScoreV1::MAX_HISTORY).to_a)

      service = SetAlpenglowVoteLatencyScore.new(@network)
      service.stub(:fetch_vote_accounts, @vote_accounts_response) do
        service.call
      end

      assert_equal ValidatorScoreV1::MAX_HISTORY, @validator1.score.reload.vote_latency_history.size
      assert_equal 0.0, @validator1.score.reload.vote_latency_history.last
    end

    test "#call skips validators not in local DB" do
      response = @vote_accounts_response + [{ "nodePubkey" => "unknown_node", "lastVote" => 99 }]

      service = SetAlpenglowVoteLatencyScore.new(@network)
      assert_nothing_raised do
        service.stub(:fetch_vote_accounts, response) do
          service.call
        end
      end
    end

    test "#call skips validators without score" do
      @validator1.validator_score_v1.destroy

      service = SetAlpenglowVoteLatencyScore.new(@network)
      service.stub(:fetch_vote_accounts, @vote_accounts_response) do
        service.call
      end

      assert_nil @validator1.reload.score
      assert_equal [2.0], @validator2.score.reload.vote_latency_history
    end

    test "#call does nothing when fetch_vote_accounts returns blank" do
      service = SetAlpenglowVoteLatencyScore.new(@network)
      service.stub(:fetch_vote_accounts, nil) do
        service.call
      end

      assert_nil @validator1.score.reload.vote_latency_history
    end
  end
end
