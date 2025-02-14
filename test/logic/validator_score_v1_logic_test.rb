# frozen_string_literal: true

require "test_helper"

# ValidatorScoreV1LogicTest
class ValidatorScoreV1LogicTest < ActiveSupport::TestCase
  include ValidatorScoreV1Logic

  def setup
    # Create our initial payload with the input values
    @batch = create(:batch)
    @validator = create(:validator)
    create(
      :validator_history,
      batch_uuid: @batch.uuid,
      validator: @validator,
      root_block: 10,
      vote_distance: 10,
      last_vote: 10,
      commission: 9
    )
    @initial_payload = {
      network: "testnet",
      batch_uuid: @batch.uuid
    }
  end

  test "set_this_batch" do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)

    assert_equal 200, p.code
    assert_equal "testnet", p.payload[:this_batch].network
    assert_equal @batch.uuid, p.payload[:this_batch].uuid
  end

  test "validators_get" do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)

    assert_equal 1, p.payload[:validators].count
    p.payload[:validators].each do |validator|
      assert_not_nil validator.validator_score_v1
      assert_equal @initial_payload[:network], validator.validator_score_v1.network
    end
  end

  test "block_vote_history_get" do
    # create enough records to confirm via logs we don't have an N+1 query when
    # getting ValidatorHistory for all accounts for this batch
    5.times do
      v = create(:validator)
      vote_acc = create(:vote_account, validator_id: v.id, account: v.account)
      create(
        :validator_history,
        network: "testnet",
        batch_uuid: @batch.uuid,
        account: v.account,
        validator: v
      )
      create(
        :vote_account_history,
        batch_uuid: @batch.uuid,
        network: "testnet",
        vote_account_id: vote_acc.id
      )
    end

    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)

    assert_equal 6, p.payload[:validators].count
    assert_equal 600000, p.payload[:total_active_stake]

    assert_not_nil p.payload[:validators].first.validator_score_v1
    assert_equal [10], p.payload[:validators]
                       .first
                       .validator_score_v1
                       .root_distance_history
    assert_equal [10], p.payload[:validators]
                       .first
                       .validator_score_v1
                       .vote_distance_history
    assert_equal 9, p.payload[:validators]
                       .last
                       .validator_score_v1
                       .commission
    assert_equal 100000, p.payload[:validators]
                       .last
                       .validator_score_v1
                       .active_stake
    assert_equal 0.167, p.payload[:validators]
                           .last
                           .validator_score_v1
                           .stake_concentration
    assert_equal [0.3518806943896684], p.payload[:validators]
                                        .last
                                        .validator_score_v1
                                        .skipped_vote_history
    assert_equal [0.3519e0], p.payload[:validators]
                              .last
                              .validator_score_v1
                              .skipped_vote_percent_moving_average_history
    refute p.payload[:validators]
            .first
            .validator_score_v1
            .delinquent
  end

  test "assign_block_and_vote_scores" do
    5.times do
      v = create(:validator)
      vote_acc = create(:vote_account, validator: v, account: v.account)
      create(
        :validator_history,
        network: "testnet",
        batch_uuid: @batch.uuid,
        account: v.account,
        validator: v
      )
      create(
        :vote_account_history,
        batch_uuid: @batch.uuid,
        network: "testnet",
        vote_account: vote_acc
      )
    end

    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)

    assert_equal [10, 5, 5, 5, 5, 5], p.payload[:root_distance_all]
    assert_equal 5.833333333333333, p.payload[:root_distance_all_average]
    assert_equal 5, p.payload[:root_distance_all_median]
    assert_equal 5.833333333333333, p.payload[:vote_distance_all_average]
    assert_equal 5, p.payload[:vote_distance_all_median]
    assert_equal p.payload[:root_distance_all_average],
                 p.payload[:this_batch].root_distance_all_average
    assert_equal p.payload[:root_distance_all_median],
                 p.payload[:this_batch].root_distance_all_median
    assert_equal p.payload[:vote_distance_all_average],
                 p.payload[:this_batch].vote_distance_all_average
    assert_equal p.payload[:vote_distance_all_median],
                 p.payload[:this_batch].vote_distance_all_median

    assert_equal 0.0, 
                 p.payload[:this_batch].skipped_vote_all_median
    assert_equal 0.3518806943896684, 
                 p.payload[:this_batch].best_skipped_vote

    assert_equal 2, p.payload[:validators]
                     .last
                     .validator_score_v1
                     .root_distance_score
    assert_equal 2, p.payload[:validators]
                     .last
                     .validator_score_v1
                     .vote_distance_score
    assert_equal -2, p.payload[:validators]
                      .last
                      .validator_score_v1
                      .stake_concentration_score
  end

  test "block_history_get" do
    Timecop.scale do
      v1 = Validator.first
      v2 = create(:validator)
      v3 = create(:validator)
      create(:validator)

      # Show that we start with one validator_block_histories
      assert_equal 0, v1.validator_block_histories.count
      assert_equal 0, ValidatorBlockHistory.count

      # 2 from previous batches. These should not be included in the stats for
      # this batch
      2.times do
        create(
          :validator_block_history,
          network: @initial_payload[:network],
          batch_uuid: "previous",
          validator: v1,
          skipped_slot_percent: 0.5
        )
      end

      # 1 from this batch
      create(
        :validator_block_history,
        network: @initial_payload[:network],
        batch_uuid: @initial_payload[:batch_uuid],
        validator: v1,
        skipped_slot_percent: 0.1
      )

      # 2 from previous batches. These should not be included in the stats for
      # this batch
      2.times do
        create(
          :validator_block_history,
          network: @initial_payload[:network],
          batch_uuid: "previous",
          validator: v2,
          skipped_slot_percent: 0.6
        )
      end

      # 1 from this batch
      create(
        :validator_block_history,
        network: @initial_payload[:network],
        batch_uuid: @initial_payload[:batch_uuid],
        validator: v2,
        skipped_slot_percent: 0.2
      )

      # 2 from previous batches
      2.times do
        create(
          :validator_block_history,
          network: @initial_payload[:network],
          batch_uuid: "previous",
          validator: v3,
          skipped_slot_percent: 0.7
        )
      end

      # 1 from this batch
      create(
        :validator_block_history,
        network: @initial_payload[:network],
        batch_uuid: @initial_payload[:batch_uuid],
        validator: v3,
        skipped_slot_percent: 0.3
      )
    end

    assert_equal 9, ValidatorBlockHistory.count


    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)

    # We should now have 3 validator_block_histories per validator
    0.upto(2).each do |i|
      assert_equal 3, p.payload[:validators][i].validator_block_histories.count
    end

    validator_block_history_stats =
      Stats::ValidatorBlockHistory.new(
        @initial_payload[:network],
        @initial_payload[:batch_uuid]
      )

    # These stats should only reflect this batch
    assert_equal 0.4667, p.payload[:avg_skipped_slot_pct_all]
    assert_equal 0.4667, validator_block_history_stats.average_skipped_slot_percent

    # These stats should only reflect this batch
    assert_equal 0.4667, p.payload[:med_skipped_slot_pct_all]
    assert_equal 0.4667, validator_block_history_stats.median_skipped_slot_percent

    assert_equal [0.1], p.payload[:validators][0]
                         .validator_score_v1
                         .skipped_slot_history

    assert_equal [0.3667], p.payload[:validators][0]
                         .validator_score_v1
                         .skipped_slot_moving_average_history

    assert_equal [0.2], p.payload[:validators][1]
                         .validator_score_v1
                         .skipped_slot_history

    assert_equal [0.4667], p.payload[:validators][1]
                         .validator_score_v1
                         .skipped_slot_moving_average_history

    assert_equal [0.3], p.payload[:validators][2]
                         .validator_score_v1
                         .skipped_slot_history

    assert_equal [0.5667], p.payload[:validators][2]
                         .validator_score_v1
                         .skipped_slot_moving_average_history

    assert_nil p.payload[:validators][3]
                         .validator_score_v1
                         .skipped_slot_history

    assert_nil p.payload[:validators][3]
                         .validator_score_v1
                         .skipped_slot_moving_average_history
  end

  test "assign_block_history_score" do
    create(
      :validator_block_history,
      network: "testnet",
      batch_uuid: @batch.uuid,
      validator: @validator,
      skipped_slot_percent: 0.1
    )

    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)
                .then(&assign_block_history_score)

    assert_equal 0.1, p.payload[:avg_skipped_slot_pct_all]
    assert_equal 0.1, p.payload[:med_skipped_slot_pct_all]
    assert_equal [0.1], p.payload[:validators]
                         .first
                         .validator_score_v1
                         .skipped_slot_history
    assert_equal 2, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .skipped_slot_score
  end

  test "#assign_block_history_score returns valid skipped_slot_score and skipped_after_score if payload is nil" do
    mock = Minitest::Mock.new(
      {
        average_skipped_slot_percent: nil,
        median_skipped_slot_percent: nil,
        average_skipped_slots_after_percent: nil,
        median_skipped_slots_after_percent: nil
      }
    )
    mock.expect :average_skipped_slot_percent, nil
    mock.expect :median_skipped_slot_percent, nil
    mock.expect :average_skipped_slots_after_percent, nil
    mock.expect :median_skipped_slots_after_percent, nil

    Stats::ValidatorBlockHistory.stub(:new, mock) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&set_this_batch)
                  .then(&validators_get)
                  .then(&block_vote_history_get)
                  .then(&assign_block_and_vote_scores)
                  .then(&block_history_get)
                  .then(&assign_block_history_score)

      assert_nil p.payload[:avg_skipped_slot_pct_all]
      assert_nil p.payload[:med_skipped_slot_pct_all]
      assert_nil p.payload[:avg_skipped_after_pct_all]
      assert_nil p.payload[:med_skipped_after_pct_all]

      score = p.payload[:validators].last.validator_score_v1
      assert_equal 0, score.skipped_slot_score
      assert_equal 0, score.skipped_after_score
    end
  end

  test "assign_software_version_score" do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)
                .then(&assign_block_history_score)
                .then(&assign_software_version_score)

    assert_equal 0, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .software_version_score
  end

  test "asign_software_version_score skips `software_version` assignment if the version is junk" do
    v = create(:validator, :with_score, network: "testnet")
    create(:validator_history, batch_uuid: @batch.uuid, validator: v)
    Validator.last.validator_score_v1.update!(software_version: "1.5.6")
    Validator.last.validator_history_last.update!(software_version: "junk")

    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)
                .then(&assign_block_history_score)
                .then(&assign_software_version_score)
                .then(&save_validators)

    assert_equal "1.5.6", p.payload[:this_batch].software_version
    assert_equal("1.5.6", Validator.last.validator_score_v1.software_version)
  end

  test "save_validators" do
    create(:validator_block_history, batch_uuid: @batch.uuid)

    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)
                .then(&assign_block_history_score)
                .then(&assign_software_version_score)
                .then(&save_validators)

    assert_equal 2, p.payload[:validators]
                     .last
                     .validator_score_v1
                     .root_distance_score
    assert_equal 2, Validator.last.validator_score_v1.root_distance_score
    assert_equal 2, Validator.last.validator_score_v1.skipped_slot_score
  end

  test "find_current_software_version \
        when most stake is over 66% \
        should return version with most stake" do
    software_versions = {
      "1.6.7"=>279919552719104317,
      "1.5.19"=>10288992031757525,
      "1.6.6"=>10483084971314635,
      "1.6.8"=>26015248337068090,
      "1.6.4"=>246312332755,
      "1.6.9"=>997717120,
      nil=>6422600362200
    }
    total_stake = 326713653288250133

    current_software_version = find_current_software_version(
      software_versions: software_versions,
      total_stake: total_stake
    )

    assert_equal "1.6.7", current_software_version
  end

  test "find_current_software_version \
    when most stake is under 66% \
    should return version earlier than one with most stake" do
      software_versions = {
        "1.6.7"=>209919552719104317,
        "1.5.19"=>17288992031757525,
        "1.6.6"=>10483084971314635,
        "1.6.8"=>26015248337068090,
        "1.6.4"=>246312332755,
        "1.6.9"=>997717120,
        nil=>6422600362200
      }
    total_stake = 326713653288250133

    current_software_version = find_current_software_version(
      software_versions: software_versions,
      total_stake: total_stake
    )

    assert_equal "1.6.7", current_software_version
  end

  test "find_current_software_version \
    when there are unexpected versions \
    should return correct version" do
    software_versions = {
      "1.6.7"=>209919552719104317,
      "1.5.19"=>17288992031757525,
      "unknown"=>10483084971314635,
      "0.202.101123"=>16015248337068090,
      nil=>6422600362200
    }
    total_stake = 23769805232343223

    current_software_version = find_current_software_version(
      software_versions: software_versions,
      total_stake: total_stake
    )

    assert_equal "1.6.7", current_software_version
  end

  test "find_current_software_version \
    when there firebase is a leading version" do
    software_versions = {
      "1.6.7"=>209919552719104317,
      "1.5.19"=>17288992031757525,
      "unknown"=>10483084971314635,
      "0.202.101123"=>360152483370680900,
      nil=>6422600362200
    }
    total_stake = software_versions.values.sum

    current_software_version = find_current_software_version(
      software_versions: software_versions,
      total_stake: total_stake
    )

    assert_equal "0.202.101123", current_software_version
  end
end
