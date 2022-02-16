# frozen_string_literal: true

require "test_helper"

# ValidatorScoreV1LogicTest
class ValidatorScoreV2LogicTest < ActiveSupport::TestCase
  include ValidatorScoreV2Logic

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      network: "testnet",
      batch_uuid: "1234"
    }
    # Create validator data needed for scores
    Validator.destroy_all
    @v1 = create(:validator, network: "testnet")
    create(:validator_score_v1,
           validator: @v1,
           root_distance_history: [2, 1, 2, 3], # average 2
           vote_distance_history: [2, 1, 2, 3], # average 2
           skipped_slot_moving_average_history: [0, 0, 0.1, 0.2]) # last record 0.2

    @v2 = create(:validator, network: "testnet")
    create(:validator_score_v1,
           validator: @v2,
           root_distance_history: [2, 4, 4, 2], # average 3
           vote_distance_history: [2, 4, 4, 2], # average 3
           skipped_slot_moving_average_history: [0, 0, 0.1, 0.3]) # last record 0.3

    @v3 = create(:validator, network: "testnet")
    create(:validator_score_v1,
           validator: @v3,
           root_distance_history: [2, 0, 2, 0], # average 1
           vote_distance_history: [2, 0, 2, 0], # average 1
           skipped_slot_moving_average_history: [0, 0, 0.1, 0.1]) # last record 0.1

    @v4 = create(:validator, network: "testnet")
    create(:validator_score_v1,
           validator: @v4,
           root_distance_history: [5, 5, 5, 5], # average 5
           vote_distance_history: [5, 3, 4, 4], # average 4
           skipped_slot_moving_average_history: [0, 0, 0.1, 0.5]) # last record 0.5

    @v5 = create(:validator, network: "testnet")
    create(:validator_score_v1,
           validator: @v5,
           root_distance_history: [5, 3, 5, 3], # average 4
           vote_distance_history: [5, 5, 4, 6], # average 5
           skipped_slot_moving_average_history: [0, 0, 0.1, 0.4]) # last record 0.4

    @validators_count = 5
  end

  test "#set_this_batch sets batch to process" do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)

    assert_equal 200, p.code
    assert_equal "testnet", p.payload[:this_batch].network
    assert_equal "1234", p.payload[:this_batch].uuid
  end

  test "validators_get" do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)

    assert_equal @validators_count, p.payload[:validators].count
    p.payload[:validators].each do |validator|
      assert_not_nil validator.validator_score_v1
      assert_not_nil validator.validator_score_v2
      assert_equal @initial_payload[:network], validator.validator_score_v1.network
      assert_equal @initial_payload[:network], validator.validator_score_v2.network
    end
  end

  test "#set_validators_groups calculates number of validators in a group" do
    p = Pipeline.new(200, @initial_payload)
                .then(&validators_get)
                .then(&set_validators_groups)

    assert_equal @validators_count, Validator.where(network: "testnet").count
    assert_equal 2, p.payload[:validators_count_in_each_group] # (validators_count / NUMBER_OF_GROUPS).ceil
  end

  test "#assign_root_distance_score sets correct scores in pipeline" do
    p = Pipeline.new(200, @initial_payload)
                .then(&validators_get)
                .then(&set_validators_groups)
                .then(&assign_root_distance_score)
                .then(&save_validators)

    assert_equal 0, p.payload[:validators].find(@v4.id).score_v2.root_distance_score # root dist avg 5
    assert_equal 0, p.payload[:validators].find(@v5.id).score_v2.root_distance_score # root dist avg 4
    assert_equal 1, p.payload[:validators].find(@v2.id).score_v2.root_distance_score # root dist avg 3
    assert_equal 1, p.payload[:validators].find(@v1.id).score_v2.root_distance_score # root dist avg 2
    assert_equal 2, p.payload[:validators].find(@v3.id).score_v2.root_distance_score # root dist avg 1
  end

  test "#assign_vote_distance_score sets correct scores in pipeline" do
    p = Pipeline.new(200, @initial_payload)
                .then(&validators_get)
                .then(&set_validators_groups)
                .then(&assign_vote_distance_score)
                .then(&save_validators)

    assert_equal 0, p.payload[:validators].find(@v5.id).score_v2.vote_distance_score # vote dist avg 5
    assert_equal 0, p.payload[:validators].find(@v4.id).score_v2.vote_distance_score # vote dist avg 4
    assert_equal 1, p.payload[:validators].find(@v2.id).score_v2.vote_distance_score # vote dist avg 3
    assert_equal 1, p.payload[:validators].find(@v1.id).score_v2.vote_distance_score # vote dist avg 2
    assert_equal 2, p.payload[:validators].find(@v3.id).score_v2.vote_distance_score # vote dist avg 1
  end

  test "#assign_skipped_slot_score sets correct scores in pipeline" do
    p = Pipeline.new(200, @initial_payload)
                .then(&validators_get)
                .then(&set_validators_groups)
                .then(&assign_skipped_slot_score)
                .then(&save_validators)

    assert_equal 0, p.payload[:validators].find(@v4.id).score_v2.skipped_slot_score # last avg 0.5
    assert_equal 0, p.payload[:validators].find(@v5.id).score_v2.skipped_slot_score # last avg 0.4
    assert_equal 1, p.payload[:validators].find(@v2.id).score_v2.skipped_slot_score # last avg 0.3
    assert_equal 1, p.payload[:validators].find(@v1.id).score_v2.skipped_slot_score # last avg 0.2
    assert_equal 2, p.payload[:validators].find(@v3.id).score_v2.skipped_slot_score # last avg 0.1
  end

  test "#save_validators saves correct values to validators calculated in the pipeline" do
    p = Pipeline.new(200, @initial_payload)
                .then(&set_this_batch)
                .then(&validators_get)
                .then(&set_validators_groups)
                .then(&assign_root_distance_score)
                .then(&assign_vote_distance_score)
                .then(&assign_skipped_slot_score)
                .then(&save_validators)

    assert_equal 1, p.payload[:validators].find(@v1.id).score_v2.root_distance_score
    assert_equal 1, p.payload[:validators].find(@v1.id).score_v2.vote_distance_score
    assert_equal 1, p.payload[:validators].find(@v1.id).score_v2.skipped_slot_score
  end
end
