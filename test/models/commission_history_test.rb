# frozen_string_literal: true

require "test_helper"

class CommissionHistoryTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'rising? \
        when commission before is smaller than after\
        should return true' do
    c = create(:commission_history, commission_before: 10, commission_after: 20)

    assert c.rising?
  end

  test 'rising? \
        when commission before is greater than after\
        should return false' do
    c = create(:commission_history, commission_before: 20, commission_after: 10)

    refute c.rising?
  end

  test "execute CommissionHistoryMailer after commit" do
    user = create(:user)
    validator = create(:validator)
    create(:user_watchlist_element, user: user, validator: validator)
    commission_history = create(:commission_history, validator: validator)

    assert_equal ActiveJob::Base.queue_adapter.enqueued_jobs[0][:args][0], "CommissionHistoryMailer"
  end
end
