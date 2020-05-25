# frozen_string_literal: true

require 'test_helper'

# CollectorLogicTest
class CollectorLogicTest < ActiveSupport::TestCase
  include CollectorLogic

  test 'collector_logic' do
    payload = { collector_id: collectors(:one).id }

    # Run the pipeline to collect the ping_times
    collector_count = Collector.count
    result = Pipeline.new(200, payload)
                     .then(&collect_ping_times)
    assert_equal 200, result.code
    assert_equal collector_count - 1, Collector.count

    # Check the values of the last PingTime record
    ping_time = PingTime.last
    assert_equal 'ABCD', ping_time.from_account
    assert_equal 'IJKL', ping_time.to_account
    assert_equal 2.238, ping_time.avg_ms
  end
end
