# frozen_string_literal: true

require "test_helper"

class AlpenglowClusterStatsQueryTest < ActiveSupport::TestCase
  setup do
    @network = "alpenglow-community"
  end

  def stat(epoch:, leader_slots:, fast: 0, slow: 0, lag_sum: 0, with_final_cert: leader_slots, user_agent: nil, network: @network)
    validator = create(:validator, network: network)
    vote_account = create(:vote_account, validator: validator, network: network, account: SecureRandom.hex)
    AlpenglowValidatorEpochStat.create!(
      network: network,
      epoch: epoch,
      vote_account: vote_account,
      validator: validator,
      leader_slots: leader_slots,
      leader_slots_with_final_cert: with_final_cert,
      leader_fast_finalized: fast,
      leader_slow_finalized: slow,
      leader_final_lag_sum: lag_sum,
      last_block_user_agent: user_agent
    )
  end

  test "#call aggregates cluster stats for the latest epoch" do
    stat(epoch: 10, leader_slots: 50, fast: 50)
    stat(epoch: 11, leader_slots: 60, fast: 10, slow: 30, lag_sum: 60, with_final_cert: 54,
         user_agent: "agave/4.3.0 (src:1; feat:2, client:Agave)")
    stat(epoch: 11, leader_slots: 40, fast: 10, slow: 30, lag_sum: 40, with_final_cert: 36,
         user_agent: "agave/4.3.0-rc.1 (src:3; feat:2, client:JitoLabs)")

    result = AlpenglowClusterStatsQuery.new(network: @network).call

    assert_equal 11, result[:epoch]
    assert_equal 2, result[:leaders]
    assert_equal 100, result[:leader_slots]
    assert_equal 80, result[:finalized_blocks]
    assert_in_delta 25.0, result[:fast_percent]
    assert_in_delta 75.0, result[:slow_percent]
    assert_in_delta 1.25, result[:average_final_lag]
    assert_in_delta 90.0, result[:final_cert_percent]
  end

  test "#call groups leaders by client and version" do
    stat(epoch: 11, leader_slots: 60, user_agent: "agave/4.3.0 (src:1; feat:2, client:JitoLabs)")
    stat(epoch: 11, leader_slots: 20, user_agent: "agave/4.3.0-rc.1 (src:3; feat:2, client:JitoLabs)")
    stat(epoch: 11, leader_slots: 15, user_agent: "agave/4.3.0 (src:4; feat:2, client:Agave)")
    stat(epoch: 11, leader_slots: 7, user_agent: "mithril")
    stat(epoch: 11, leader_slots: 5, user_agent: nil)

    clients = AlpenglowClusterStatsQuery.new(network: @network).call[:clients]

    assert_equal ["JitoLabs", "Agave", "mithril", "Not reported"], clients.map { |c| c[:client] }
    assert_empty clients.find { |c| c[:client] == "mithril" }[:versions]
    jito = clients.first
    assert_equal 2, jito[:leaders]
    assert_equal 80, jito[:leader_slots]
    assert_in_delta 74.77, jito[:leader_slots_percent], 0.01
    assert_equal ["4.3.0", "4.3.0-rc.1"], jito[:versions]
  end

  test "#call uses requested epoch when it has data" do
    stat(epoch: 10, leader_slots: 50)
    stat(epoch: 11, leader_slots: 60)

    assert_equal 10, AlpenglowClusterStatsQuery.new(network: @network, epoch: "10").call[:epoch]
    assert_equal 11, AlpenglowClusterStatsQuery.new(network: @network, epoch: "999").call[:epoch]
  end

  test "#call returns nil percentages when there are no finalized blocks" do
    stat(epoch: 11, leader_slots: 0, with_final_cert: 0)

    result = AlpenglowClusterStatsQuery.new(network: @network).call

    assert_nil result[:fast_percent]
    assert_nil result[:average_final_lag]
    assert_nil result[:final_cert_percent]
  end

  test "#call returns nil for networks without stats" do
    stat(epoch: 11, leader_slots: 10)

    assert_nil AlpenglowClusterStatsQuery.new(network: "mainnet").call
    assert_empty AlpenglowClusterStatsQuery.new(network: "mainnet").epochs
  end
end
