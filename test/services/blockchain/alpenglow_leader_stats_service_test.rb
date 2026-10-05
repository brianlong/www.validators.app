# frozen_string_literal: true

require "test_helper"

module Blockchain
  class AlpenglowLeaderStatsServiceTest < ActiveSupport::TestCase
    setup do
      @network = "alpenglow-community"
      @leader_a = create(:validator, network: @network, account: "LeaderA")
      @leader_b = create(:validator, network: @network, account: "LeaderB")
      @vote_account_a = create(:vote_account, validator: @leader_a, network: @network, account: "VoteA")
      @vote_account_b = create(:vote_account, validator: @leader_b, network: @network, account: "VoteB")
    end

    def footer(slot, leader:, final_cert_slot: nil, finalization: nil, epoch: 10, user_agent: nil, processed: false)
      Blockchain::AlpenglowCommunityBlockFooter.create!(
        slot_number: slot,
        epoch: epoch,
        leader: leader,
        block_user_agent: user_agent,
        final_cert_slot: final_cert_slot,
        finalization: finalization,
        processed: processed
      )
    end

    def add_tail(from_slot)
      (from_slot...(from_slot + Blockchain::AlpenglowLeaderStatsService::FINALITY_LAG)).each do |slot|
        footer(slot, leader: "LeaderTail")
      end
    end

    def stat_for(vote_account, epoch: 10)
      AlpenglowValidatorEpochStat.find_by(vote_account_id: vote_account.id, epoch: epoch)
    end

    def call_service
      Blockchain::AlpenglowLeaderStatsService.new(network: @network).call
    end

    test "#call counts produced blocks and footer completeness per leader" do
      footer(100, leader: "LeaderA", user_agent: "agave/4.3.0")
      footer(101, leader: "LeaderA", final_cert_slot: 100, finalization: :fast, user_agent: "agave/4.3.1")
      footer(102, leader: "LeaderB", final_cert_slot: 101, finalization: :slow)
      add_tail(103)

      assert_equal 3, call_service

      stat_a = stat_for(@vote_account_a)
      assert_equal 2, stat_a.leader_slots
      assert_equal 1, stat_a.leader_slots_with_final_cert
      assert_equal "agave/4.3.1", stat_a.last_block_user_agent
      assert_equal @leader_a.id, stat_a.validator_id
      assert_equal 1, stat_for(@vote_account_b).leader_slots
    end

    test "#call attributes finalization to the leader of the finalized block using the first certificate only" do
      footer(100, leader: "LeaderA")
      footer(101, leader: "LeaderB", final_cert_slot: 100, finalization: :fast)
      footer(102, leader: "LeaderB", final_cert_slot: 100, finalization: :fast)
      footer(103, leader: "LeaderB", final_cert_slot: 101, finalization: :slow)
      footer(105, leader: "LeaderA", final_cert_slot: 103, finalization: :slow)
      add_tail(106)

      call_service

      stat_a = stat_for(@vote_account_a)
      stat_b = stat_for(@vote_account_b)
      assert_equal [1, 0, 1], [stat_a.leader_fast_finalized, stat_a.leader_slow_finalized, stat_a.leader_final_lag_sum]
      assert_equal [0, 2, 4], [stat_b.leader_fast_finalized, stat_b.leader_slow_finalized, stat_b.leader_final_lag_sum]
    end

    test "#call skips certificates already counted in a previous batch" do
      footer(100, leader: "LeaderA", processed: true)
      footer(101, leader: "LeaderB", final_cert_slot: 100, finalization: :fast, processed: true)
      footer(102, leader: "LeaderB", final_cert_slot: 100, finalization: :fast)
      add_tail(103)

      call_service

      assert_equal 0, stat_for(@vote_account_a)&.leader_fast_finalized.to_i
    end

    test "#call leaves recent footers unprocessed and increments counters on next run" do
      footer(100, leader: "LeaderA")
      add_tail(101)

      call_service
      assert Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 100).processed
      refute Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 101).processed

      footer(200, leader: "LeaderA")
      add_tail(201)
      Blockchain::AlpenglowCommunityBlockFooter.where(leader: "LeaderTail").update_all(processed: true)
      call_service

      assert_equal 2, stat_for(@vote_account_a).leader_slots
    end

    test "#call uses the epoch of each footer" do
      footer(100, leader: "LeaderA", epoch: 10)
      footer(101, leader: "LeaderA", epoch: 11)
      add_tail(102)

      call_service

      assert_equal 1, stat_for(@vote_account_a, epoch: 10).leader_slots
      assert_equal 1, stat_for(@vote_account_a, epoch: 11).leader_slots
    end

    test "#call skips leaders without validator but still marks footers processed" do
      footer(100, leader: "UnknownLeader")
      add_tail(101)

      assert_equal 1, call_service
      assert_equal 0, AlpenglowValidatorEpochStat.count
      assert Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 100).processed
    end

    test "worker does not process footers on stage" do
      footer(100, leader: "LeaderA")
      add_tail(101)

      Rails.env.stub(:stage?, true) { Blockchain::AlpenglowLeaderStatsWorker.new.perform("network" => @network) }

      refute Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 100).processed
      assert_equal 0, AlpenglowValidatorEpochStat.count
    end

    test "#call returns 0 when there is nothing to process" do
      assert_equal 0, call_service
    end
  end
end
