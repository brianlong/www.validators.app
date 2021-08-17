# frozen_string_literal: true

require 'test_helper'

class ValidatorHistoryTest < ActiveSupport::TestCase
  test 'relationships belongs_to validator' do
    validator = create(:validator)
    validator_history = create(:validator_history, account: validator.account)

    assert_equal validator, validator_history.validator
  end
end
