# frozen_string_literal: true

require 'test_helper'

class ReportLogicTest < ActiveSupport::TestCase

  test "#update_total_active_stake" do
    network = 'mainnet'
    batch = create(:batch, :mainnet)

    batch_uuid = batch.uuid

    assert_equal network, report.network
    assert_equal batch_uuid, report.batch_uuid

    binding.pry
  end
end
