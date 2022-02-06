require "test_helper"

class PingThingTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "attributes_from_raw should return correct attributes" do
    raw = {
      amount: "1",
      time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer"
    }.to_json

    token = @user.api_token
    params = PingThing.attributes_from_raw(raw, token)

    assert params[:amount].is_a? Integer
    assert params[:response_time].is_a? Integer
    refute params[:signature].blank?
    refute params[:transaction_type].blank?
  end
end
