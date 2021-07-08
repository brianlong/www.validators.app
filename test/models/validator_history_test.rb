# frozen_string_literal: true

require 'test_helper'

class ValidatorHistoryTest < ActiveSupport::TestCase
  setup do
    @validator = create(:validator, account: 'acc-123')
  end

  test 'previous should return single previous record' do
    vh3 = create(
      :validator_history,
      account: 'other-account',
      created_at: 2.seconds.ago
    )
    vh2 = create(
      :validator_history,
      account: @validator.account,
      created_at: 2.minutes.ago
    )
    vh1 = create(
      :validator_history,
      account: @validator.account,
      created_at: 1.minute.ago
    )
    vh0 = create(
      :validator_history,
      account: @validator.account
    )

    assert_equal vh1, vh0.previous
  end

  test 'when there is a previous record with changed commission \
        new commission_history should be created' do
    create(
      :validator_history,
      account: @validator.account,
      created_at: 1.minute.ago,
      commission: 20
    )

    refute CommissionHistory.exists?

    vh = create(
      :validator_history,
      account: @validator.account,
      commission: 10
    )

    assert CommissionHistory.exists?
    assert_equal vh.commission, CommissionHistory.last.commission_after
    assert_equal @validator, CommissionHistory.last.validator
  end
end
