# frozen_string_literal: true

require "test_helper"

module Blockchain
  class SetVoteLatencyScoreTest < ActiveSupport::TestCase

    setup do
      @network = "mainnet"
      @account = "validator_account_1"
      @validator = create(:validator, :with_score, network: @network, account: @account)
      5.times do |i|
        create(:mainnet_block, slot_number: i, blockhash: "blockhash_#{i}")
      end
    end

    test "#call sets vote latency score for validators" do
      create(:mainnet_transaction, account_key_1: @account, recent_blockhash: "blockhash_0", block: Blockchain::MainnetBlock.last)
      Blockchain::SetVoteLatencyScore.new(@network).call

      assert_equal 0, @validator.score.reload.vote_latency_score
      assert_equal [4], @validator.score.reload.vote_latency_history
      assert Blockchain::MainnetBlock.all.map(&:processed).all?
    end

    test "#call sets correct score while there are multiple transactions" do
      5.times do 
        create(:mainnet_transaction, account_key_1: @account, recent_blockhash: "blockhash_2", block: Blockchain::MainnetBlock.last)
      end
      5.times do
        create(:mainnet_transaction, account_key_1: @account, recent_blockhash: "blockhash_3", block: Blockchain::MainnetBlock.last)
      end
      Blockchain::SetVoteLatencyScore.new(@network).call

      assert_equal 2, @validator.score.reload.vote_latency_score
      assert_equal [1.5], @validator.score.reload.vote_latency_history
      assert Blockchain::MainnetBlock.all.map(&:processed).all?
    end

    test "#call pushes to vote_latency_history up to maximum" do
      create(:mainnet_transaction, account_key_1: @account, recent_blockhash: "blockhash_0", block: Blockchain::MainnetBlock.last)
      @validator.score.update(vote_latency_history: (0..ValidatorScoreV1::MAX_HISTORY).to_a)
      Blockchain::SetVoteLatencyScore.new(@network).call

      assert_equal ValidatorScoreV1::MAX_HISTORY, @validator.score.reload.vote_latency_history.size
      assert_equal 4, @validator.score.reload.vote_latency_history.last
    end
  end
end
