require "test_helper"

class PingThingRawTest < ActiveSupport::TestCase

  test "attributes_from_raw should return correct attributes" do
    ping_thing_raw = create(
      :ping_thing_raw,
      raw_data: {
        amount: "1",
        time: "234",
        signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
        transaction_type: "transfer"
      }.to_json
    )

    params = ping_thing_raw.attributes_from_raw

    assert params[:amount].is_a? Integer
    assert params[:response_time].is_a? Integer
    refute params[:signature].blank?
    refute params[:transaction_type].blank?
  end
end
