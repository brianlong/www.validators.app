# frozen_string_literal: true

require 'test_helper'

class ValidatorScoreV1Test < ActiveSupport::TestCase
  test 'relationship to validator' do
    validator = FactoryBot.create(:validator)
    score = validator.create_validator_score_v1

    assert_not_nil score
    assert_equal validator.id, score.validator_id
  end

  test 'calculate_total_score assigns a score of 0 if commission is 100' do
    validator_score_v1 = create(
      :validator_score_v1,
      network: 'mainnet',
      commission: 100,
      root_distance_score: 2,
      vote_distance_score: 2,
      skipped_slot_score: 2
    )

    assert_equal 0, validator_score_v1.total_score
  end

  test 'assign_published_information_score' do
    validator = FactoryBot.create(:validator)
    score = validator.create_validator_score_v1
    assert_equal 1, score.published_information_score
    validator.www_url = 'http://www.example.com'
    validator.details = 'Test details'
    validator.save
    score.save
    score.reload
    assert_equal 2, score.published_information_score
  end

  test 'assign_security_report_score' do
    score = FactoryBot.create(:validator_score_v1)
    assert_equal 1, score.security_report_score
  end

  test 'assign_software_version_score persists a software_version_score' do
    score = create(:validator_score_v1, software_version: '1.5.4')
    score.assign_software_version_score
    assert(score.software_version_score.present?)
  end

  test 'assign_software_version_score preserves the existing value if junk is passed' do
    score = create(:validator_score_v1, software_version: 'foo', software_version_score: 1)
    score.assign_software_version_score
    assert_equal 1, score.reload.software_version_score
  end
end
