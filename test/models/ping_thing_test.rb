require "test_helper"

# frozen_string_literal: true

class PingThingTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  setup do
    @user = create(:user)
    @params = {
      amount: "1",
      response_time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      network: 'testnet',
      user_id: @user.id,
      reported_at: DateTime.now
    }
    @ping_thing = build(:ping_thing, user_id: @user.id, success: nil)
  end

  test "validates application length" do
    application = "a" * 81
    @ping_thing.application = application

    refute @ping_thing.valid?

    @ping_thing.application = "application"
    assert @ping_thing.valid?
  end


  test "success different values" do
    ActiveRecord::Type::Boolean::FALSE_VALUES.each do |value|
      @ping_thing.success = nil

      assert @ping_thing.valid?
      refute @ping_thing.success
    end

    @ping_thing.success = nil
    assert @ping_thing.valid? # it's valid because column is allowed to have null value
    assert_nil @ping_thing.success

    @ping_thing.success = true
    assert @ping_thing.valid?
    assert @ping_thing.success

    @ping_thing.success = "true"
    assert @ping_thing.valid?
    assert @ping_thing.success

    @ping_thing.success = "I am also true" # String is also casted to true
    assert @ping_thing.valid?
    assert @ping_thing.success
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

    PingThing.commitment_levels.each_key do |key|
      pt.commitment_level = key
      assert pt.valid?
      assert_equal key, pt.commitment_level 
    end

    PingThing.commitment_levels.each_value do |value|
      pt.commitment_level = value
      assert pt.valid?
      assert_equal PingThing.commitment_levels.keys[value], pt.commitment_level 
    end
  end

  test "commitment_level raise argument error when wrong level is being assigned" do
    pt = build(:ping_thing, user_id: @user.id)
    
    # string instead of integer
    assert_raise ArgumentError do
      pt.commitment_level = "0"
    end

    # Integer out of range
    assert_raise ArgumentError do
       pt.commitment_level = 3
    end

    # Random string instead of valid commitment levels
    assert_raise ArgumentError do
      pt.commitment_level = "I am not valid :C"
    end
  end

  test "commitment_level allows nils" do
    pt = build(:ping_thing, user_id: @user.id, commitment_level: nil)
    
    assert_nil pt.commitment_level
    assert pt.valid?
  end

  test "success field is true by default" do
    pt = PingThing.new

    assert pt.success
  end

  test "creating new record brodcasts message" do
    pt = build(:ping_thing, user_id: @user.id, commitment_level: nil)
    channel = "ping_thing_channel"

    assert_broadcasts channel, 0

    pt.save
    hash = {}
    hash.merge!(pt.to_builder.attributes!)
    hash.merge!(pt.user.to_builder.attributes!)

    assert_broadcasts channel, 1
    assert_broadcast_on(channel, hash)
  end

  test ".for_reported_at_range_and_network scope returns correct ping things" do
    pt = create(:ping_thing, :testnet, reported_at: 10.minutes.ago)
    3.times do
      create(:ping_thing, :testnet, reported_at: rand(4.minutes.ago..Time.now))
    end

    pings = PingThing.for_reported_at_range_and_network("testnet", 5.minutes.ago, Time.now)

    assert_equal 3, pings.count
    assert_not pings.include? pt

    pings = PingThing.for_reported_at_range_and_network("testnet", 12.minutes.ago, Time.now)
    assert_equal 4, pings.count
    assert pings.include? pt
  end
end
