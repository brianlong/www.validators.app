# frozen_string_literal: true

require "test_helper"

class PingThingRawTest < ActiveSupport::TestCase

  test "attributes_from_raw should return correct attributes" do
    reported_at = "2021-07-01T11:02:12"
    raw_data = {
      amount: "1",
      time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      reported_at: reported_at
    }

    ping_thing_raw = create(
      :ping_thing_raw,
      raw_data: raw_data.to_json
    )

    params = ping_thing_raw.attributes_from_raw

    assert params[:amount].is_a? Integer
    assert params[:response_time].is_a? Integer
    assert_equal raw_data[:amount].to_i, params[:amount]
    assert_equal raw_data[:time].to_i, params[:response_time]
    assert_equal raw_data[:signature], params[:signature]
    assert_equal raw_data[:transaction_type], params[:transaction_type]
    assert_equal reported_at.to_datetime, params[:reported_at]
  end
end
