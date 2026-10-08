# frozen_string_literal: true

require "test_helper"

module Blockchain
  class AlpenglowEpochStatsServiceTest < ActiveSupport::TestCase
    setup do
      @network = "alpenglow-community"
      @epoch_schedule = Blockchain::EpochSchedule.new("slotsPerEpoch" => 1000, "firstNormalEpoch" => 0, "firstNormalSlot" => 0)
      @leader_a = create(:validator, network: @network, account: "LeaderA")
      @leader_b = create(:validator, network: @network, account: "LeaderB")
      @vote_account_a = create(:vote_account, validator: @leader_a, network: @network, account: "VoteA")
      @vote_account_b = create(:vote_account, validator: @leader_b, network: @network, account: "VoteB")
    end

    def footer(slot, leader:, final_cert_slot: nil, finalization: nil, epoch: 10, user_agent: nil, processed: false, **certificates)
      Blockchain::AlpenglowCommunityBlockFooter.create!(
        **certificates,
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
      (from_slot...(from_slot + Blockchain::AlpenglowEpochStatsService::FINALITY_LAG)).each do |slot|
        footer(slot, leader: "LeaderTail")
      end
    end

    def stat_for(vote_account, epoch: 10)
      AlpenglowValidatorEpochStat.find_by(vote_account_id: vote_account.id, epoch: epoch)
    end

    def call_service
      Blockchain::AlpenglowEpochStatsService.new(network: @network, epoch_schedule: @epoch_schedule).call
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

      Rails.env.stub(:stage?, true) { Blockchain::AlpenglowEpochStatsWorker.new.perform("network" => @network) }

      refute Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 100).processed
      assert_equal 0, AlpenglowValidatorEpochStat.count
    end

    def bitmap(ranks, length: 2)
      bytes = Array.new((length + 7) / 8, 0)
      ranks.each { |rank| bytes[rank / 8] |= 1 << (rank % 8) }
      [0, length].pack("CS<") + bytes.pack("C*")
    end

    def create_ranks(epoch, vote_accounts, status: :verified)
      vote_accounts.each_with_index do |account, rank|
        AlpenglowEpochRank.create!(
          network: @network, epoch: epoch, rank: rank, vote_account: account,
          validator_identity: "Identity#{account}", bls_pubkey: "bls#{account}", stake: 100 - rank, status: status
        )
      end
    end

    test "#call counts notar reward votes once per certificate" do
      create_ranks(0, %w[VoteA VoteB])
      footer(100, leader: "LeaderA", epoch: 0, notar_reward_slot: 92, notar_reward_signers: bitmap([0]))
      footer(101, leader: "LeaderA", epoch: 0, notar_reward_slot: 92, notar_reward_signers: bitmap([0]))
      footer(102, leader: "LeaderA", epoch: 0, notar_reward_slot: 94, notar_reward_signers: bitmap([0, 1]))
      add_tail(103)

      call_service

      assert_equal [2, 2], [stat_for(@vote_account_a, epoch: 0).notar_reward_slots, stat_for(@vote_account_a, epoch: 0).notar_votes]
      assert_equal [2, 1], [stat_for(@vote_account_b, epoch: 0).notar_reward_slots, stat_for(@vote_account_b, epoch: 0).notar_votes]
    end

    test "#call counts fast and slow finalization signatures" do
      create_ranks(0, %w[VoteA VoteB])
      footer(100, leader: "LeaderA", epoch: 0)
      footer(101, leader: "LeaderA", epoch: 0, final_cert_slot: 100, finalization: :fast, final_signers: bitmap([0, 1]))
      footer(102, leader: "LeaderB", epoch: 0, final_cert_slot: 101, finalization: :slow,
                  final_signers: bitmap([1]), final_notar_signers: bitmap([0, 1]))
      add_tail(103)

      call_service

      stat_a = stat_for(@vote_account_a, epoch: 0)
      stat_b = stat_for(@vote_account_b, epoch: 0)
      assert_equal [1, 1, 1, 0, 1], [stat_a.fast_finalized_slots, stat_a.fast_final_signatures, stat_a.slow_finalized_slots,
                                     stat_a.slow_final_signatures, stat_a.slow_notar_signatures]
      assert_equal [1, 1, 1, 1, 1], [stat_b.fast_finalized_slots, stat_b.fast_final_signatures, stat_b.slow_finalized_slots,
                                     stat_b.slow_final_signatures, stat_b.slow_notar_signatures]
      assert_equal 2, stat_a.leader_slots
      assert_equal 1, stat_a.leader_fast_finalized
    end

    test "#call counts skip votes and marks skips of notarized slots as divergent" do
      create_ranks(0, %w[VoteA VoteB])
      footer(100, leader: "LeaderA", epoch: 0, skip_reward_slot: 92, skip_reward_signers: bitmap([1]),
                  notar_reward_slot: 92, notar_reward_signers: bitmap([0]))
      footer(101, leader: "LeaderA", epoch: 0, skip_reward_slot: 93, skip_reward_signers: bitmap([0, 1]))
      add_tail(102)

      call_service

      assert_equal [1, 0], [stat_for(@vote_account_a, epoch: 0).skip_votes, stat_for(@vote_account_a, epoch: 0).divergent_skip_votes]
      assert_equal [2, 1], [stat_for(@vote_account_b, epoch: 0).skip_votes, stat_for(@vote_account_b, epoch: 0).divergent_skip_votes]
    end

    test "#call uses ranks of the certificate slot epoch" do
      create_ranks(0, %w[VoteA VoteB])
      create_ranks(1, %w[VoteB VoteA])
      footer(1000, leader: "LeaderA", epoch: 1, notar_reward_slot: 999, notar_reward_signers: bitmap([0]))
      footer(1001, leader: "LeaderA", epoch: 1, notar_reward_slot: 1000, notar_reward_signers: bitmap([0]))
      add_tail(1002)

      call_service

      assert_equal 1, stat_for(@vote_account_a, epoch: 0).notar_votes
      assert_equal 1, stat_for(@vote_account_b, epoch: 1).notar_votes
      assert_equal 0, stat_for(@vote_account_a, epoch: 1).notar_votes
    end

    test "#call stops before footers whose certificates need ranks that are not verified yet" do
      create_ranks(0, %w[VoteA VoteB])
      create_ranks(1, %w[VoteA VoteB], status: :finalized)
      footer(998, leader: "LeaderA", epoch: 0, notar_reward_slot: 990, notar_reward_signers: bitmap([0]))
      footer(1008, leader: "LeaderA", epoch: 1, notar_reward_slot: 1000, notar_reward_signers: bitmap([0]))
      add_tail(1009)

      assert_equal 1, call_service

      assert Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 998).processed
      refute Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 1008).processed
      assert_equal 1, stat_for(@vote_account_a, epoch: 0).notar_votes
    end

test "#call waits for provisional ranks as well" do
  create_ranks(0, %w[VoteA VoteB], status: :provisional)
  footer(100, leader: "LeaderA", epoch: 0, notar_reward_slot: 92, notar_reward_signers: bitmap([0]))
  add_tail(101)

  assert_equal 0, call_service
end

test "#call skips voting stats without waiting when ranks were rejected" do
  create_ranks(0, %w[VoteA VoteB], status: :rejected)
  footer(100, leader: "LeaderA", epoch: 0, notar_reward_slot: 92, notar_reward_signers: bitmap([0]))
  add_tail(101)

  assert_equal 1, call_service

  stat_a = stat_for(@vote_account_a, epoch: 0)
  assert_equal [1, 0, 0], [stat_a.leader_slots, stat_a.notar_reward_slots, stat_a.notar_votes]
end

    test "#call processes footers without voting stats when an epoch has no ranks" do
      footer(100, leader: "LeaderA", epoch: 0, notar_reward_slot: 92, notar_reward_signers: bitmap([0]))
      add_tail(101)

      call_service

      stat_a = stat_for(@vote_account_a, epoch: 0)
      assert_equal [1, 0, 0], [stat_a.leader_slots, stat_a.notar_reward_slots, stat_a.notar_votes]
      assert Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 100).processed
    end

    test "#call assigns leader stats to the vote account from finalized ranks instead of the active one" do
      other_vote_account = create(:vote_account, validator: @leader_a, network: @network, account: "VoteA2")
      @leader_a.set_active_vote_account(other_vote_account)
      AlpenglowEpochRank.create!(
        network: @network, epoch: 10, rank: 0, vote_account: "VoteA", validator_identity: "LeaderA",
        bls_pubkey: "blsA", stake: 100, status: :finalized
      )
      footer(100, leader: "LeaderA")
      add_tail(101)

      call_service

      assert_equal 1, stat_for(@vote_account_a).leader_slots
      assert_nil stat_for(other_vote_account)
    end

    test "#call falls back to the active vote account when the epoch has no finalized ranks" do
      other_vote_account = create(:vote_account, validator: @leader_a, network: @network, account: "VoteA2")
      @leader_a.set_active_vote_account(other_vote_account)
      footer(100, leader: "LeaderA")
      add_tail(101)

      call_service

      assert_equal 1, stat_for(other_vote_account).leader_slots
    end

    test "#call stops waiting for ranks that stay unverified too long and skips their votes" do
      create_ranks(1, %w[VoteA VoteB], status: :finalized)
      old_footer = footer(1008, leader: "LeaderA", epoch: 1, notar_reward_slot: 1000, notar_reward_signers: bitmap([0]))
      old_footer.update_columns(created_at: 61.minutes.ago)
      add_tail(1009)

      assert_equal 1, call_service

      assert old_footer.reload.processed
      stat_a = stat_for(@vote_account_a, epoch: 1)
      assert_equal [1, 0, 0], [stat_a.leader_slots, stat_a.notar_reward_slots, stat_a.notar_votes]
    end

    test "#call returns 0 when there is nothing to process" do
      assert_equal 0, call_service
    end
  end
end
