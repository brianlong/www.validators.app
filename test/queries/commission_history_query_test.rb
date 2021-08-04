require 'test_helper'

class CommissionHistoryQueryTest < ActiveSupport::TestCase
  setup do
    val1 = create(:validator, :with_score, account: 'acc1', network: 'testnet')
    val2 = create(:validator, :with_score, account: 'acc2', network: 'testnet')

    create(:commission_history, validator: val1)
    create(:commission_history, validator: val2, created_at: 32.days.ago)
  end

  test 'commission_history_query \
        should include results from correct time period' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
    ).all_records

    assert_equal 1, result.size
    assert_equal 'acc1', result.last.account
  end

  test 'commission_history_query \
        when query given \
        should include results from correct validators' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      time_from: 33.day.ago,
      time_to: DateTime.now
    ).by_query('acc2')

    assert_equal 1, result.size
    assert_equal 'acc2', result.last.account
  end
end
