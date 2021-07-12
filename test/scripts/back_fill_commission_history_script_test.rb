# frozen_string_literal: true

require 'test_helper'

class AddCurrentEpochScriptTest < ActiveSupport::TestCase
  setup do
    v = create(:validator, network: 'testnet')
    commission = 10
    create(:batch, network: 'testnet')
    create(:epoch_history, network: 'testnet', created_at: 10.minutes.ago)

    10.times do |i|
      this_commission = i % 3 == 0 ? commission + i : commission
      ValidatorHistory.create(
        account: v.account,
        commission: this_commission,
        network: v.network,
        created_at: i.minutes.ago
      )
    end
  end

  test 'commission histories are added correctly' do
    refute CommissionHistory.exists?
    load(Rails.root.join('script', 'back_fill_commission_history.rb'))
    assert_equal 5, CommissionHistory.count
    assert_equal [10.0, 16.0, 10.0, 13.0, 10.0], CommissionHistory.pluck(:commission_after)
    assert_equal [19.0, 10.0, 16.0, 10.0, 13.0], CommissionHistory.pluck(:commission_before)
  end
end