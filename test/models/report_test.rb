# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test 'create object' do
    report = Report.create(
      network: 'testnet',
      batch_uuid: SecureRandom.uuid,
      name: 'test_report',
      payload: { 'ping' => 'pong' }
    )
    assert_equal 'pong', report.payload['ping']
  end
end
