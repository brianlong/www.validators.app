require 'test_helper'

class CommissionHistoryQueryTest < ActiveSupport::TestCase
  setup do
    # Setup data centers with data center hosts
    data_center = create(:data_center, :china)
    data_center_host = create(:data_center_host, data_center: data_center)

    val1 = create(:validator, :with_score, account: 'acc1', network: 'testnet')
    val2 = create(:validator, :with_score, account: 'acc2', network: 'testnet')

    [val1, val2].each do |val|
      create(:validator_ip, :active, validator: val, data_center_host: data_center_host)
    end

    create(:commission_history, validator: val1)
    create(:commission_history, validator: val2, created_at: 370.days.ago)
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
      time_from: 371.day.ago,
      time_to: DateTime.now
    ).by_query('acc2')

    assert_equal 1, result.size
    assert_equal 'acc2', result.last.account
  end
end
