# frozen_string_literal: true

require "test_helper"

class CommissionHistoryTest < ActiveSupport::TestCase
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
end
