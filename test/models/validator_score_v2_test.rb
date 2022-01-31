# TODO drop this file after switching to ValidatorScoreV2
# frozen_string_literal: true

require 'test_helper'

class ValidatorScoreV2Test < ActiveSupport::TestCase
  setup do
    @batch = create(:batch, software_version: '1.8.14')
    @validator = create(:validator, network: 'mainnet')
    @validator_score_v1 = create(
      :validator_score_v1,
      validator: @validator,
      network: 'mainnet',
      software_version: @batch.software_version,
      published_information_score: 1,
      security_report_score: 1,
      software_version_score: 2,
      stake_concentration_score: 0,
      data_center_concentration_score: 0,
      authorized_withdrawer_score: 0,
      delinquent: false
    )
    @validator_score_v2 = create(
      :validator_score_v2,
      validator: @validator,
      network: 'mainnet',
      root_distance_score: 2,
      vote_distance_score: 2,
      skipped_slot_score: 2
    )
  end

  test 'relationship to validator' do
    assert_not_nil @validator_score_v2
    assert_equal @validator.id, @validator_score_v2.validator_id
  end

  test '#calculate_total_score assigns a score of 0 if commission is 100' do
    @validator_score_v2.update(
      commission: 100,
    )

    assert_equal 0, @validator_score_v2.total_score
    assert_equal "N/A", @validator_score_v2.displayed_total_score
  end

  test '#calculate_total_score assigns a score of 0 if validator has admin_warning' do
    @validator.update(admin_warning: 'test warning')
    @validator_score_v2.calculate_total_score

    assert_equal 0, @validator_score_v2.total_score
    assert_equal "N/A", @validator_score_v2.displayed_total_score
  end

  test '#calculate_total_score correctly calculates score including proper values from v1 and v2' do
    assert_equal 10, @validator_score_v2.calculate_total_score

    @validator_score_v1.update(
      stake_concentration_score: -2
    )
    @validator_score_v2.update(
      root_distance_score: 1,
      vote_distance_score: 1,
      skipped_slot_score: 1
    )

    assert_equal 6, @validator_score_v2.calculate_total_score
  end

  test '#delinquent? returns corrent boolean value' do
    @validator_score_v2.delinquent?
  end
end
