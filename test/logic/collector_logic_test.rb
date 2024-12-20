# frozen_string_literal: true

require 'test_helper'

# CollectorLogicTest
class CollectorLogicTest < ActiveSupport::TestCase
  include CollectorLogic

  setup do
    @user = create(:user)
    @collector = create(:collector, user_id: @user.id)
  end

  test 'collector_logic' do
    payload = { collector_id: @collector.id }

    # Run the pipeline to collect the ping_times
    collector_count = Collector.count
    result = Pipeline.new(200, payload)
                     .then(&ping_times_guard)
                     .then(&ping_times_read)
                     .then(&ping_times_calculate_stats)
                     .then(&ping_times_save)
                     .then(&log_errors)

    assert_equal 200, result.code

    # Show that the collector record was deleted
    assert_equal collector_count - 1, Collector.count

    # Check the values of the last PingTime record
    ping_time = PingTime.last
    assert_equal 'ABCD', ping_time.from_account
    assert_equal 'IJKL', ping_time.to_account
    assert_equal 2.238, ping_time.avg_ms

    # Check the values of the PingTimeStat record
    ping_time_stat = PingTimeStat.last
    assert_equal ping_time.batch_uuid, ping_time_stat.batch_uuid
    assert_equal 0.881, ping_time_stat.overall_min_time
    assert_equal 3.428, ping_time_stat.overall_max_time
    assert_equal 1.738, ping_time_stat.overall_average_time
  end

  test '#ping_times_guard returns 400 if there are some fields missing in pipeline' do
    @collector.update!(payload: { ping_times: nil }.to_json)

    payload = { collector_id: @collector.id }
    result = Pipeline.new(200, payload)
                      .then(&ping_times_guard)

    assert_equal 400, result.code
    assert result.message.include?('No payload field')
  end
end
