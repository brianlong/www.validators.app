# frozen_string_literal: true

require 'test_helper'

class ProcessPingThingsServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test 'service \
        with correct input \
        should create new data' do

    10.times do |n|
      create(:ping_thing_raw, api_token: @user.api_token, network: 'testnet')
    end

    ProcessPingThingsService.new(records_count: 10).call

    assert PingThingRaw.all.blank?
    assert_equal 10, PingThing.count
  end

  test "#call with correct input correctly assigns all fields" do

    ptr = create(:ping_thing_raw, api_token: @user.api_token)
    ptr_attributes = ptr.attributes_from_raw

    assert_difference "PingThing.count" do
      ProcessPingThingsService.new(records_count: 1).call
    end

    pt = PingThing.last

    assert PingThingRaw.all.blank?

    assert_equal pt.amount, ptr_attributes[:amount]
    assert_equal pt.application, ptr_attributes[:application]
    assert_equal pt.commitment_level, ptr_attributes[:commitment_level]
    assert_equal pt.response_time, ptr_attributes[:response_time]
    assert_equal pt.signature, ptr_attributes[:signature]
    assert_equal pt.transaction_type, ptr_attributes[:transaction_type]
    assert pt.success
  end

  test "#call with one invalid ping_thing_raw, destroys both raws, creates one ping_thing, no error" do
    create(:ping_thing_raw, :invalid_commitment_level, api_token: @user.api_token)
    ptr = create(:ping_thing_raw, api_token: @user.api_token)
    ptr_attributes = ptr.attributes_from_raw

    assert_difference "PingThing.count" do
      ProcessPingThingsService.new(records_count: 2).call
    end
    
    pt = PingThing.last

    assert PingThingRaw.all.blank?

    assert_equal pt.amount, ptr_attributes[:amount]
    assert_equal pt.application, ptr_attributes[:application]
    assert_equal pt.commitment_level, ptr_attributes[:commitment_level]
    assert_equal pt.response_time, ptr_attributes[:response_time]
    assert_equal pt.signature, ptr_attributes[:signature]
    assert_equal pt.transaction_type, ptr_attributes[:transaction_type]
    assert pt.success
  end

  test "#call success is set to true when success param is not present in raw data" do
    ptr = create(:ping_thing_raw, :success_empty, api_token: @user.api_token)
    ptr_attributes = ptr.attributes_from_raw

    assert_difference "PingThing.count" do
      ProcessPingThingsService.new(records_count: 1).call
    end
    
    pt = PingThing.last

    assert PingThingRaw.all.blank?
    assert pt.success
  end

  test 'service \
      with incorrect input \
      should not create new data \
      but should delete raws' do

    10.times do |n|
      create(:ping_thing_raw, api_token: nil)
    end

    ProcessPingThingsService.new(records_count: 10).call
    assert PingThingRaw.all.blank?
    refute PingThing.exists?
  end

  test 'service \
        when there is no raw data \
        should not return error' do

    assert ProcessPingThingsService.new(records_count: 10).call
  end
end