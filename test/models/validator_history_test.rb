# frozen_string_literal: true

require 'test_helper'

class ValidatorHistoryTest < ActiveSupport::TestCase
  test 'relationships belongs_to validator' do
    validator = create(:validator)
    validator_history = create(:validator_history, account: validator.account)

    assert_equal validator, validator_history.validator
  end

  test 'scope #most_recent_epoch_credits_by_account' do
    validator = create(:validator)
    time = Date.today
    dates_with_epoch_credits = [[time - 2.day, 100],[time - 1.day, 200], [time, 300]]

    dates_with_epoch_credits.each do |arr|
      create(
        :validator_history, 
        account: validator.account, 
        created_at: arr[0], 
        epoch_credits: arr[1]
      )
    end

    most_recent_epoch_credits = ValidatorHistory.most_recent_epoch_credits_by_account

    assert_equal Validator.all.size, most_recent_epoch_credits.size
    assert_equal validator.account, most_recent_epoch_credits[1].account
    assert_equal 300, most_recent_epoch_credits[1].epoch_credits
    assert_equal time, most_recent_epoch_credits[1].created_at
  end
end
