# frozen_string_literal: true

require 'test_helper'

# ValidatorScoreV1LogicTest
class ValidatorScoreV1LogicTest < ActiveSupport::TestCase
  include ValidatorScoreV1Logic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      network: 'testnet',
      batch_uuid: '1234'
    }
  end

  test 'set_this_batch' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)

    assert_equal 200, p.code
    assert_equal 'testnet', p.payload[:this_batch].network
    assert_equal '1234', p.payload[:this_batch].uuid
  end

  test 'get_validators' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)

    assert_equal 1, p.payload[:validators].count
    assert_not_nil p.payload[:validators].first.validator_score_v1
  end

  test 'block_vote_history_get' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
    # byebug
    assert_equal 1, p.payload[:validators].count
    assert_not_nil p.payload[:validators].first.validator_score_v1
    assert_equal [1], p.payload[:validators]
                       .first
                       .validator_score_v1
                       .root_distance_history
    assert_equal [1], p.payload[:validators]
                       .first
                       .validator_score_v1
                       .vote_distance_history
  end

  test 'block_vote_score' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
    # byebug
    assert_equal [1], p.payload[:root_distance_all]
    assert_equal 1.0, p.payload[:root_distance_all_average]
    assert_equal 1.0, p.payload[:root_distance_all_median]
    assert_equal 1.0, p.payload[:vote_distance_all_average]
    assert_equal 1.0, p.payload[:vote_distance_all_median]
    assert_equal 2, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .root_distance_score
    assert_equal 2, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .vote_distance_score
  end

  test 'block_history_get' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)

    assert_equal 0.1, p.payload[:avg_skipped_slot_pct_all]
    assert_equal 0.1, p.payload[:med_skipped_slot_pct_all]
    assert_equal 0.1, p.payload[:avg_skipped_after_pct_all]
    assert_equal 0.1, p.payload[:med_skipped_after_pct_all]
    assert_equal [0.1], p.payload[:validators]
                         .first
                         .validator_score_v1
                         .skipped_slot_history
    assert_equal [0.1], p.payload[:validators]
                         .first
                         .validator_score_v1
                         .skipped_after_history
  end

  test 'assign_block_history_score' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)
                .then(&assign_block_history_score)

    assert_equal 0.1, p.payload[:avg_skipped_slot_pct_all]
    assert_equal 0.1, p.payload[:med_skipped_slot_pct_all]
    assert_equal 0.1, p.payload[:avg_skipped_after_pct_all]
    assert_equal 0.1, p.payload[:med_skipped_after_pct_all]
    assert_equal [0.1], p.payload[:validators]
                         .first
                         .validator_score_v1
                         .skipped_slot_history
    assert_equal [0.1], p.payload[:validators]
                         .first
                         .validator_score_v1
                         .skipped_after_history
    assert_equal 2, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .skipped_slot_score
    assert_equal 2, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .skipped_after_score
  end

  test 'asign_software_version_score' do
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

  test 'save_validators' do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&block_vote_history_get)
                .then(&assign_block_and_vote_scores)
                .then(&block_history_get)
                .then(&assign_block_history_score)
                .then(&assign_software_version_score)
                .then(&save_validators)
    # byebug
    assert_equal 2, p.payload[:validators]
                     .first
                     .validator_score_v1
                     .root_distance_score
    assert_equal 2, Validator.first.validator_score_v1.root_distance_score
    assert_equal 2, Validator.first.validator_score_v1.skipped_slot_score
    assert_equal 2, Validator.first.validator_score_v1.skipped_after_score
  end
end
