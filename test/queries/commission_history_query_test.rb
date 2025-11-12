# frozen_string_literal: true

require 'test_helper'

class CommissionHistoryQueryTest < ActiveSupport::TestCase
  setup do
    # Setup data centers with data center hosts
    data_center = create(:data_center, :china)
    data_center_host = create(:data_center_host, data_center: data_center)

    val1 = create(:validator, :with_score, account: 'acc1', network: 'testnet')
    val2 = create(:validator, :with_score, account: 'acc2', network: 'testnet')
    val3 = create(:validator, :with_score, account: 'acc3', network: 'testnet')

    [val1, val2, val3].each do |val|
      create(:validator_ip, :active, validator: val, data_center_host: data_center_host)
    end

    # Create commission histories with different change types
    create(:commission_history, validator: val1, commission_before: 5.0, commission_after: 10.0) # increase
    create(:commission_history, validator: val2, commission_before: 10.0, commission_after: 5.0, created_at: 370.days.ago) # decrease
    create(:commission_history, validator: val3, commission_before: 8.0, commission_after: 12.0, created_at: 6.years.ago) # increase
    create(:commission_history, validator: val1, commission_before: 15.0, commission_after: 8.0) # decrease
  end

  test 'commission_history_query \
        should include all results when no time filter given' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
    ).all_records

    assert_equal 4, result.size
  end

  test 'commission_history_query \
        should filter by time when time_from given' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      time_from: 5.years.ago
    ).all_records

    assert_equal 3, result.size
  end

  test 'commission_history_query \
        when query given \
        should include results from correct validators' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      time_from: 371.days.ago,
      time_to: DateTime.now
    ).by_query('acc2')

    assert_equal 1, result.size
    assert_equal 'acc2', result.last.account
  end

  test 'commission_history_query \
        should filter by commission increases when change_type is increase' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      change_type: 'increase'
    ).all_records

    assert_equal 2, result.size
    
    # Verify all results are increases (commission_after > commission_before)
    result.each do |record|
      assert record.commission_after > record.commission_before,
             "Expected commission increase but got #{record.commission_before} -> #{record.commission_after}"
    end
  end

  test 'commission_history_query \
        should filter by commission decreases when change_type is decrease' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      change_type: 'decrease'
    ).all_records

    assert_equal 2, result.size
    
    # Verify all results are decreases (commission_after < commission_before)
    result.each do |record|
      assert record.commission_after < record.commission_before,
             "Expected commission decrease but got #{record.commission_before} -> #{record.commission_after}"
    end
  end

  test 'commission_history_query \
        should return all records when change_type is nil' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      change_type: nil
    ).all_records

    assert_equal 4, result.size
  end

  test 'commission_history_query \
        should filter by query and change_type together' do
    result = CommissionHistoryQuery.new(
      network: 'testnet',
      change_type: 'decrease'
    ).by_query('acc1')

    assert_equal 1, result.size
    assert_equal 'acc1', result.first.account
    assert result.first.commission_after < result.first.commission_before
  end

  test 'commission_history_query \
        total_count should respect change_type filter' do
    query_obj = CommissionHistoryQuery.new(
      network: 'testnet',
      change_type: 'increase'
    )

    count = query_obj.total_count
    assert_equal 2, count
  end

  test 'commission_history_query \
        total_count with query should respect change_type filter' do
    query_obj = CommissionHistoryQuery.new(
      network: 'testnet',
      change_type: 'decrease'
    )

    count = query_obj.total_count('acc1')
    assert_equal 1, count
  end
end
