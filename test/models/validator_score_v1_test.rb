# frozen_string_literal: true

require 'test_helper'

class ValidatorScoreV1Test < ActiveSupport::TestCase
  test 'relationship to validator' do
    validator = FactoryBot.create(:validator)
    score = validator.create_validator_score_v1

    assert_not_nil score
    assert_equal validator.id, score.validator_id
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
    score = FactoryBot.create(:validator_score_v1, :with_validator)
    assert_equal 1, score.security_report_score
  end
end
