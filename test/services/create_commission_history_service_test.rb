# frozen_string_literal: true

require 'test_helper'

class CreateCommissionHistoryServiceTest < ActiveSupport::TestCase
  setup do
    @validator = create(:validator, account: 'commission-account')
    create(
      :validator_history,
      account: @validator.account,
      commission: 10,
      created_at: 1.minute.ago
    )
  end

  test 'when commission is different \
        commission_history should be created' do
    vh = create(
      :validator_history,
      account: @validator.account,
      commission: 20,
      batch_uuid: 'last-batch-123'
    )

    result = CreateCommissionHistoryService.new(vh).call

    assert result.success?
    assert_equal 10, result.payload.commission_before
    assert_equal 20, result.payload.commission_after
    assert_equal vh.batch_uuid, result.payload.batch_uuid
  end

  test 'when commission is the same \
        commission_history should not be created' do
    vh = create(
      :validator_history,
      account: @validator.account,
      commission: 10,
      batch_uuid: 'last-batch-123'
    )

    result = CreateCommissionHistoryService.new(vh).call

    assert result.success?
    refute result.payload
  end
end
