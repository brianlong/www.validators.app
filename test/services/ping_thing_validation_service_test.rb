require 'test_helper'

class PingThingValidationServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test 'service \
        with correct input \
        should create new data' do

    10.times do |n|
      create(:ping_thing_raw, api_token: @user.api_token)
    end

    PingThingValidationService.new(records_count: 10).call

    assert PingThingRaw.all.blank?
    assert 10, PingThing.count
  end

  test 'service \
      with incorrect input \
      should not create new data \
      but should delete raws' do

    10.times do |n|
      create(:ping_thing_raw, api_token: nil)
    end

    PingThingValidationService.new(records_count: 10).call

    assert PingThingRaw.all.blank?
    refute PingThing.exists?
  end

  test 'service \
        when there is no raw data \
        should not return error' do

    assert PingThingValidationService.new(records_count: 10).call
  end
end