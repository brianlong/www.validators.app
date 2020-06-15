# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test 'the truth' do
    report = Report.create(
      network: 'testnet',
      name: 'test_report',
      payload: { 'ping' => 'pong' }
    )
    assert_equal 'pong', report.payload['ping']
  end
end
