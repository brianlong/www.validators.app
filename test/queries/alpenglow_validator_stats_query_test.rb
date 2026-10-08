# frozen_string_literal: true

require "test_helper"

class AlpenglowValidatorStatsQueryTest < ActiveSupport::TestCase
  setup do
    @network = "alpenglow-community"
  end

  def stat(account, epoch: 224, stake: nil, status: :verified, **counters)
    validator = create(:validator, network: @network, account: "Identity#{account}", name: "Validator #{account}")
    vote_account = create(:vote_account, validator: validator, network: @network, account: account)
    if stake
      AlpenglowEpochRank.create!(
        network: @network, epoch: epoch, rank: AlpenglowEpochRank.where(epoch: epoch).count, vote_account: account,
        validator_identity: validator.account, bls_pubkey: "bls#{account}", stake: stake, status: status
      )
    end
    AlpenglowValidatorEpochStat.create!(network: @network, epoch: epoch, vote_account: vote_account, validator: validator, **counters)
  end

  def query(**options)
    AlpenglowValidatorStatsQuery.new(network: @network, epoch: 224, **options).call
  end

  test "#call returns validator metrics with stake and rank" do
    stat("VoteA", stake: 500_000_000_000, notar_votes: 9, notar_reward_slots: 10, fast_final_signatures: 3, fast_finalized_slots: 4,
                  slow_final_signatures: 1, slow_finalized_slots: 2, skip_votes: 5, divergent_skip_votes: 2,
                  leader_slots: 8, leader_slots_with_final_cert: 6, leader_fast_finalized: 1, leader_slow_finalized: 3,
                  leader_final_lag_sum: 6, last_block_user_agent: "agave/4.3.0 (src:1; feat:2, client:JitoLabs)")

    validator = query[:validators].first

    assert_equal "Validator VoteA", validator[:validator_name]
    assert_equal "IdentityVoteA", validator[:validator_account]
    assert_equal "VoteA", validator[:vote_account]
    assert_equal 500_000_000_000, validator[:stake]
    assert_equal 0, validator[:rank]
    assert_in_delta 90.0, validator[:notar_participation]
    assert_in_delta 75.0, validator[:fast_inclusion]
    assert_in_delta 50.0, validator[:slow_inclusion]
    assert_in_delta 25.0, validator[:leader_fast_percent]
    assert_in_delta 1.5, validator[:average_final_lag]
    assert_in_delta 75.0, validator[:final_cert_percent]
    assert_equal [5, 2, 8], validator.values_at(:skip_votes, :divergent_skip_votes, :leader_slots)
    assert_equal ["JitoLabs", "4.3.0"], validator.values_at(:client, :version)
  end

  test "#call sorts by metric with missing values last in both directions" do
    stat("VoteHigh", stake: 3, notar_votes: 10, notar_reward_slots: 10)
    stat("VoteLow", stake: 2, notar_votes: 5, notar_reward_slots: 10)
    stat("VoteNone", stake: 1, leader_slots: 4)

    assert_equal %w[VoteHigh VoteLow VoteNone], query(sort_by: "notar_participation")[:validators].map { |v| v[:vote_account] }
    assert_equal %w[VoteLow VoteHigh VoteNone],
                 query(sort_by: "notar_participation", direction: "asc")[:validators].map { |v| v[:vote_account] }
    assert_equal %w[VoteNone VoteHigh VoteLow], query(sort_by: "leader_slots")[:validators].map { |v| v[:vote_account] }
  end

  test "#call falls back to default sort for unknown columns" do
    stat("VoteA", notar_votes: 1, notar_reward_slots: 1)

    assert_equal "notar_participation", query(sort_by: "id; DROP TABLE validators")[:sort_by]
  end

  test "#call paginates results" do
    5.times { |i| stat("Vote#{i}", stake: 100 - i) }

    result = query(sort_by: "stake", page: 2, per: 2)

    assert_equal 5, result[:total_count]
    assert_equal %w[Vote2 Vote3], result[:validators].map { |v| v[:vote_account] }
  end

  test "#call reports missing user agent the same way as cluster stats" do
    stat("VoteA", leader_slots: 1)

    assert_equal ["Not reported", nil], query[:validators].first.values_at(:client, :version)
  end

  test "#call does not use stake from provisional ranks" do
    stat("VoteA", stake: 100, status: :provisional)

    assert_nil query[:validators].first[:stake]
  end
end
