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
    assert_equal @validator_score_v1.id, @validator_score_v2.validator_score_v1.id
  end

  test '#calculate_total_score assigns a score of 0 if commission is 100' do
    @validator_score_v1.update(commission: 100)

    assert @validator.private_validator?
    assert_equal 0, @validator_score_v2.calculate_total_score
    assert_equal "N/A", @validator_score_v2.displayed_total_score
  end

  test '#calculate_total_score assigns a score of 0 if validator has admin_warning' do
    @validator.update(admin_warning: 'test warning')

    assert_equal 0, @validator_score_v2.calculate_total_score
    assert_equal "N/A", @validator_score_v2.displayed_total_score
  end

  test '#calculate_total_score correctly calculates score including proper values from v1 and v2' do
    assert_equal 10, @validator_score_v2.calculate_total_score
    assert_equal 2, @validator_score_v2.root_distance_score
    assert_equal 2, @validator_score_v2.vote_distance_score
    assert_equal 2, @validator_score_v2.skipped_slot_score

    @validator_score_v2.update_columns(
      root_distance_score: 1,
      vote_distance_score: 1,
      skipped_slot_score: 1
    )

    assert_equal 7, @validator_score_v2.calculate_total_score
  end

  test '#calculate_total_score correctly calculates total score based on cosensus_mods values in v1' do
    validator_with_consensus_mods = create(:validator, :with_consensus_mods_true)
    validator_score_v1 = create(
      :validator_score_v1,
      validator: validator_with_consensus_mods,
      software_version: @batch.software_version,
      published_information_score: 1,
      security_report_score: 1,
      software_version_score: 2,
      stake_concentration_score: 0,
      data_center_concentration_score: 0,
      authorized_withdrawer_score: 0,
      delinquent: false
    )
    validator_score_v2 = create(
      :validator_score_v2,
      validator: validator_with_consensus_mods,
      root_distance_score: 2,
      vote_distance_score: 2,
      skipped_slot_score: 2
    )
    assert_equal -2, validator_score_v1.consensus_mods_score # reduced by 2
    assert_equal 0, validator_score_v1.security_report_score # reduced by 1
    assert_equal 4, validator_score_v1.calculate_total_score # reduced by (2+1)
    assert_equal 7, validator_score_v2.calculate_total_score # reduced by (2+1)
  end

  test '#delinquent? returns corrent boolean value' do
    refute @validator_score_v2.delinquent?

    @validator_score_v2.validator_score_v1.delinquent = true
    assert @validator_score_v2.delinquent?
  end
end
