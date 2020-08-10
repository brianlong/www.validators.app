# frozen_string_literal: true

require 'test_helper'

class ValidatorScoreV1Test < ActiveSupport::TestCase
  test 'relationship to validator' do
    validator = FactoryBot.create(:validator)
    score = validator.create_validator_score_v1

    assert_not_nil score
    assert_equal validator.id, score.validator_id
  end
end
