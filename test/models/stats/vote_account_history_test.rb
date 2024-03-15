# frozen_string_literal: true

require 'test_helper'

module Stats
  # Query Objects for searching for ValidatorHistory relations and objects
  class VoteAccountHistoryTest < ActiveSupport::TestCase
    def setup
      super

      network = 'testnet'
      batch_uuid = create(:batch).uuid

      @val = create(:validator, network: network)
      @vote_account = create(:vote_account, validator: @val, network: network)
      @vote_account_histories = [
        create(:vote_account_history, network: network, batch_uuid: batch_uuid,
               slot_index_current: 1, credits_current: 140, vote_account: @vote_account),
        create(:vote_account_history, network: network, batch_uuid: batch_uuid,
               slot_index_current: 2, credits_current: 120, vote_account: @vote_account),
        create(:vote_account_history, network: network, batch_uuid: batch_uuid,
               slot_index_current: 4, credits_current: 100, vote_account: @vote_account),
        create(:vote_account_history, network: network, batch_uuid: batch_uuid,
               slot_index_current: 8, credits_current: 80, vote_account: @vote_account),
        create(:vote_account_history, network: network, batch_uuid: batch_uuid,
               slot_index_current: 16, credits_current: 60, vote_account: @vote_account),
        create(:vote_account_history, network: network, batch_uuid: batch_uuid,
               slot_index_current: 32, credits_current: 40, vote_account: @vote_account),
        create(:vote_account_history, slot_index_current: 64, credits_current: 220, vote_account: @vote_account),
      ]

      @vahq = Stats::VoteAccountHistory.new(network, batch_uuid)

      @vah_skipped_vote_percent_ma =
        @vote_account_histories[0...-1].map(&:skipped_vote_percent_moving_average)
      @vah_credit_current =
        @vote_account_histories[0...-1].map(&:credits_current)
      @vah_slot_index_current =
        @vote_account_histories[0...-1].map(&:slot_index_current)
      @vah_skipped_vote_percent =
        @vote_account_histories[0...-1].map(&:skipped_vote_percent)
    end

    def teardown
      super

      @vote_account_histories.each(&:destroy)
    end

    test 'average_skipped_vote_percent' do
      expected = @vah_skipped_vote_percent.sum / @vah_skipped_vote_percent.size
      assert_equal expected, @vahq.average_skipped_vote_percent
    end

    test 'median_skipped_vote_percent' do
      expected = @vah_skipped_vote_percent.sort[@vah_skipped_vote_percent.size / 2]
      assert_equal expected, @vahq.median_skipped_vote_percent
    end

    test 'average_skipped_vote_percent_moving_average' do
      expected = @vah_skipped_vote_percent_ma.sum / @vah_skipped_vote_percent_ma.size
      expected = expected.round(8) # depend on DB column decimal (10,4)
      assert_equal expected, @vahq.average_skipped_vote_percent_moving_average
    end

    test 'median_skipped_vote_percent_moving_average' do
      expected = @vah_skipped_vote_percent_ma[@vah_skipped_vote_percent_ma.size / 2]
      assert_equal expected, @vahq.median_skipped_vote_percent_moving_average
    end

    test 'vote_account_history_skipped' do
      expected = @vah_skipped_vote_percent
      assert_equal expected, @vahq.vote_account_history_skipped
    end

    test 'credits_current_max' do
      expected = @vah_credit_current.max
      assert_equal expected, @vahq.credits_current_max
    end

    test 'slot_index_current' do
      expected = @vah_slot_index_current.max
      assert_equal expected, @vahq.slot_index_current
    end

    test 'skipped_vote_percent_best' do
      expected =
        (@vah_slot_index_current.max - @vah_credit_current.max) / @vah_slot_index_current.max.to_f
      assert_equal expected, @vahq.skipped_vote_percent_best
    end

    test 'top_skipped_vote_percent' do
      expected = [-139.0, -99.0, -74.0, -57.75, -46.75, -39.0]
      assert_equal expected, @vahq.top_skipped_vote_percent.map(&:first)
    end

    test 'skipped_votes_stats' do
      expected = {
        min: -139.0, max: -0.25, median: -9.0, average: -39.0, best: -3.375
      }
      assert_equal expected, @vahq.skipped_votes_stats
    end

    test 'skipped_votes_stats with history' do
      expected = {
        min: -139.0, max: -0.25, median: -9.0, average: -39.0, best: -3.375,
        history: [-139.0, -59.0, -24.0, -9.0, -2.75, -0.25]
      }
      assert_equal expected, @vahq.skipped_votes_stats(with_history: true)
    end

    test 'skipped_vote_moving_average_stats' do
      expected = {
        min: -0.139e3, max: -0.39e2, median: -0.5775e2, average: -0.7591666667e2
      }
      assert_equal expected, @vahq.skipped_vote_moving_average_stats
    end

    test 'skipped_vote_moving_average_stats with history' do
      expected = {
        min: -0.139e3, max: -0.39e2, median: -0.5775e2, average: -0.7591666667e2
      }
      expected_history = [-139.0, -99.0, -74.0, -57.75, -46.75, -39.0]
      assert_equal expected, @vahq.skipped_vote_moving_average_stats(with_history: false)
      assert_equal expected_history, @vahq.skipped_vote_moving_average_stats(with_history: true)[:history].map(&:first)
    end

    test 'average of skipped vote percent moving average calculated correctly' do
      create(:vote_account_history, batch_uuid: '1-2-3', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.1)
      create(:vote_account_history, batch_uuid: '1-2-3', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.2)
      create(:vote_account_history, batch_uuid: '1-2-3', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.3)
      create(:vote_account_history, batch_uuid: '1234', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.3)
      create(:vote_account_history, batch_uuid: '1234', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.4)
      average1 = Stats::VoteAccountHistory.new('testnet', '1234')
                                          .average_skipped_vote_percent_moving_average
      average2 = Stats::VoteAccountHistory.new('testnet', '1-2-3')
                                          .average_skipped_vote_percent_moving_average

      assert_equal 0.35, average1
      assert_equal 0.2, average2
    end

    test 'median of skipped vote percent moving average calculated correctly' do
      create(:vote_account_history, batch_uuid: '1-2-3', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.1)
      create(:vote_account_history, batch_uuid: '1-2-3', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.2)
      create(:vote_account_history, batch_uuid: '1-2-3', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.3)
      create(:vote_account_history, batch_uuid: '1234', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.3)
      create(:vote_account_history, batch_uuid: '1234', vote_account: @vote_account)
        .update(skipped_vote_percent_moving_average: 0.4)

      median1 = Stats::VoteAccountHistory.new('testnet', '1234')
                                         .median_skipped_vote_percent_moving_average
      median2 = Stats::VoteAccountHistory.new('testnet', '1-2-3')
                                         .median_skipped_vote_percent_moving_average

      assert_equal 0.4, median1
      assert_equal 0.2, median2
    end
  end
end
