require 'test_helper'
require 'sidekiq/testing'

class PingThingWorkerTest < ActiveSupport::TestCase
  test 'worker \
        with correct input \
        should create new data' do

    50.times do |n|
      create(:ping_thing_raw)
    end

    Sidekiq::Testing.inline! do
      PingThingWorker.perform_async

      assert PingThingRaw.all.blank?
    end
  end

end
