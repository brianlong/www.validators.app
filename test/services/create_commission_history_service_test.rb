# frozen_string_literal: true

require "test_helper"

class CreateCommissionHistoryServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @batch = create(:batch, network: 'testnet')
    @user = create(:user)
    @validator = create(
      :validator,
      account: 'commission-account',
      network: 'testnet'
    )
    @epoch = create(:epoch_history, network: 'testnet', batch_uuid: @batch.uuid)
    create(:user_watchlist_element, user: @user, validator: @validator)

  end

  test 'when commission is different \
        commission_history should be created' do
    score = create(
      :validator_score_v1,
      validator: @validator,
      commission: 10,
      network: 'testnet'
    )

    score.update(commission: 20)
    result = CreateCommissionHistoryService.new(score).call

    assert result.success?
    assert_equal 10, result.payload.commission_before
    assert_equal 20, result.payload.commission_after
    assert_equal @batch.uuid, result.payload.batch_uuid
  end

  test "emails are sent when new commission_history is created" do
    score = create(
      :validator_score_v1,
      validator: @validator,
      commission: 10,
      network: "testnet"
    )

    assert_enqueued_emails 1 do
      result = CreateCommissionHistoryService.new(score).call
      assert result.success?
    end
  end
end
