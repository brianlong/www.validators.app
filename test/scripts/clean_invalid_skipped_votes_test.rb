# frozen_string_literal: true

require "test_helper"

class CleanInvalidSkippedVotesTest < ActiveSupport::TestCase
  def load_script(network)
    @network = network
    path = Rails.root.join("script", "one_time_scripts", "clean_invalid_skipped_votes.rb").to_s

    capture_io { eval(File.read(path)) }
  end

  setup do
    @validator = create(:validator, network: "testnet")
    @vote_account = create(:vote_account, validator: @validator, network: "testnet")
  end

  test "script removes out of range skipped vote values for given network" do
    score = create(
      :validator_score_v1,
      validator: @validator,
      network: "testnet",
      skipped_vote_history: [0.05, -5_459_992.11, nil, 0.1],
      skipped_vote_percent_moving_average_history: [0.05, -928_406.2, 0.1]
    )
    valid_vah = create(:vote_account_history, vote_account: @vote_account, network: "testnet")
    valid_vah.update_column(:skipped_vote_percent_moving_average, 0.2)
    invalid_vah = create(:vote_account_history, vote_account: @vote_account, network: "testnet")
    invalid_vah.update_column(:skipped_vote_percent_moving_average, -928_406.2)
    valid_batch = create(:batch, network: "testnet", best_skipped_vote: 0.03, skipped_vote_all_median: -2.5)
    invalid_batch = create(:batch, network: "testnet", best_skipped_vote: -5_000_000.0, skipped_vote_all_median: 3_000.0)

    load_script("testnet")

    score.reload
    assert_equal [0.05, nil, nil, 0.1], score.skipped_vote_history
    assert_equal [0.05, nil, 0.1], score.skipped_vote_percent_moving_average_history.map { |v| v&.to_f }
    assert_equal 0.2, valid_vah.reload.skipped_vote_percent_moving_average
    assert_nil invalid_vah.reload.skipped_vote_percent_moving_average
    assert_in_delta 0.03, valid_batch.reload.best_skipped_vote, 0.0001
    assert_in_delta(-2.5, valid_batch.skipped_vote_all_median, 0.0001)
    assert_nil invalid_batch.reload.best_skipped_vote
    assert_nil invalid_batch.skipped_vote_all_median
  end

  test "script does not touch other networks" do
    mainnet_validator = create(:validator, network: "mainnet")
    score = create(
      :validator_score_v1,
      validator: mainnet_validator,
      network: "mainnet",
      skipped_vote_history: [-5_459_992.11]
    )
    batch = create(:batch, network: "mainnet", best_skipped_vote: -5_000_000.0)

    load_script("testnet")

    assert_equal [-5_459_992.11], score.reload.skipped_vote_history
    assert_equal(-5_000_000.0, batch.reload.best_skipped_vote)
  end
end
