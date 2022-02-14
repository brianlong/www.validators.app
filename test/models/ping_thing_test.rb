require "test_helper"

# frozen_string_literal: true

class PingThingTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @params = {
      amount: "1",
      response_time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      network: 'testnet',
      user_id: @user.id
    }
  end

  test "create with correct data should succeed" do
    assert PingThing.create @params
  end

  test "create with no user should return error" do
    pt = PingThing.create @params.except(:user_id)

    refute pt.valid?
    assert_equal ["User must exist", "User can't be blank"], pt.errors.full_messages
  end

  test "create with no required data should return error" do
    pt = PingThing.create @params.except(:response_time, :signature, :network)

    errors = pt.errors.full_messages

    refute pt.valid?
    assert errors.include? "Response time can't be blank"
    assert errors.include? "Signature can't be blank"
    assert errors.include? "Network can't be blank"
  end

  test "create with too short transaction_type should return error" do
    @params[:signature] = "abc"
    pt = PingThing.create @params

    refute pt.valid?
    assert_equal ["Signature is too short (minimum is 64 characters)"], pt.errors.full_messages
  end

  test "commitment_level is being correctly assigned and returns correct values" do
    pt = build(:ping_thing, user_id: @user.id)

    pt.commitment_level = 0
    assert pt.valid?
    assert_equal 'processed', pt.commitment_level 

    pt.commitment_level = 'processed'
    assert pt.valid?
    assert_equal 'processed', pt.commitment_level 

    pt.commitment_level = 1
    assert pt.valid?
    assert_equal 'confirmed', pt.commitment_level

    pt.commitment_level = 'confirmed'
    assert pt.valid?
    assert_equal 'confirmed', pt.commitment_level 

    pt.commitment_level = 2
    assert pt.valid?
    assert_equal 'finalized', pt.commitment_level

    pt.commitment_level = 'finalized'
    assert pt.valid?
    assert_equal 'finalized', pt.commitment_level
  end

  test "commitment_level raise argument error when wrong level is being assigned" do
    pt = build(:ping_thing, user_id: @user.id)
    
    assert_raise ArgumentError do
       pt.commitment_level = 3
    end

    assert_raise ArgumentError do
      pt.commitment_level = "I am not valid :C"
   end
  end

  test "success field is true by default" do
    pt = PingThing.new

    assert pt.success
  end
end
