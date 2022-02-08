require "test_helper"

class PingThingTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "create with correct data should succeed" do
    assert PingThing.create(
      amount: "1",
      response_time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      token: 'token',
      network: 'testnet',
      user_id: @user.id
    )
  end

  test "create with no user should return error" do
    pt = PingThing.create(
      amount: "1",
      response_time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      network: "testnet",
      token: 'token'
    )

    refute pt.valid?
    assert_equal ["User must exist", "User can't be blank"], pt.errors.full_messages
  end

  test "create with no required data should return error" do
    pt = PingThing.create(
      amount: "1",
      transaction_type: "transfer",
      user_id: @user.id
    )

    errors = pt.errors.full_messages

    refute pt.valid?
    assert errors.include? "Token can't be blank"
    assert errors.include? "Response time can't be blank"
    assert errors.include? "Signature can't be blank"
    assert errors.include? "Network can't be blank"
  end

  test "create with too short transaction_type should return error" do
    pt = PingThing.create(
      amount: "1",
      response_time: "234",
      signature: "5zxrAiJ",
      transaction_type: "transfer",
      token: "token",
      network: "testnet",
      user_id: @user.id
    )

    refute pt.valid?
    assert_equal ["Signature is too short (minimum is 64 characters)"], pt.errors.full_messages
  end
end
