require 'test_helper'
require 'sidekiq/testing'

class PingThingWorkerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test 'worker \
        with correct input \
        should create new data' do

    10.times do |n|
      create(:ping_thing_raw, api_token: @user.api_token)
    end

    Sidekiq::Testing.inline! do
      PingThingWorker.perform_async

      assert PingThingRaw.all.blank?
      assert 10, PingThing.count
    end
  end

  test 'worker \
      with incorrect input \
      should not create new data \
      but should delete raws' do

    10.times do |n|
      create(:ping_thing_raw, api_token: nil)
    end

    Sidekiq::Testing.inline! do
    PingThingWorker.perform_async

    assert PingThingRaw.all.blank?
    refute PingThing.exists?
    end
  end

  test 'worker \
        when there is no raw data \
        should not return error' do

    Sidekiq::Testing.inline! do
      worker = PingThingWorker.perform_async

      assert worker
    end
  end

end
