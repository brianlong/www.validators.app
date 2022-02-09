require 'test_helper'
#frozen_string_literal: true

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
end
