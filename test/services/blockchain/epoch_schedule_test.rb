# frozen_string_literal: true

require "test_helper"

module Blockchain
  class EpochScheduleTest < ActiveSupport::TestCase
    test "#epoch_for computes epochs without warmup" do
      schedule = Blockchain::EpochSchedule.new(
        "slotsPerEpoch" => 54_000, "firstNormalEpoch" => 0, "firstNormalSlot" => 0
      )

      assert_equal 0, schedule.epoch_for(0)
      assert_equal 0, schedule.epoch_for(53_999)
      assert_equal 1, schedule.epoch_for(54_000)
      assert_equal 185, schedule.epoch_for(10_007_788)
    end

    test "#epoch_for computes warmup epochs" do
      schedule = Blockchain::EpochSchedule.new(
        "slotsPerEpoch" => 8192, "firstNormalEpoch" => 8, "firstNormalSlot" => 8160
      )

      assert_equal 0, schedule.epoch_for(0)
      assert_equal 0, schedule.epoch_for(31)
      assert_equal 1, schedule.epoch_for(32)
      assert_equal 1, schedule.epoch_for(95)
      assert_equal 2, schedule.epoch_for(96)
      assert_equal 7, schedule.epoch_for(8159)
      assert_equal 8, schedule.epoch_for(8160)
      assert_equal 9, schedule.epoch_for(8160 + 8192)
    end

    test ".fetch builds schedule from the network RPC" do
      result = { "slotsPerEpoch" => 54_000, "firstNormalEpoch" => 0, "firstNormalSlot" => 0 }
      rpc = Minitest::Mock.new
      rpc.expect(:call, result, ["getEpochSchedule"])

      Blockchain::JsonRpcRequest.stub(:new, ->(urls) { assert_equal NETWORK_URLS["alpenglow-community"], urls; rpc }) do
        assert_equal 54_000, Blockchain::EpochSchedule.fetch("alpenglow-community").slots_per_epoch
      end
      rpc.verify
    end

    test ".fetch raises when schedule is unavailable" do
      rpc = Minitest::Mock.new
      rpc.expect(:call, nil, ["getEpochSchedule"])

      Blockchain::JsonRpcRequest.stub(:new, ->(_urls) { rpc }) do
        assert_raises(RuntimeError) { Blockchain::EpochSchedule.fetch("testnet") }
      end
    end

    test "#first_slot_in_epoch returns the first slot of warmup and normal epochs" do
      schedule = Blockchain::EpochSchedule.new(
        "slotsPerEpoch" => 8192, "firstNormalEpoch" => 8, "firstNormalSlot" => 8160
      )

      assert_equal 0, schedule.first_slot_in_epoch(0)
      assert_equal 32, schedule.first_slot_in_epoch(1)
      assert_equal 96, schedule.first_slot_in_epoch(2)
      assert_equal 8160, schedule.first_slot_in_epoch(8)
      assert_equal 8160 + 8192, schedule.first_slot_in_epoch(9)
      (0..12).each { |epoch| assert_equal epoch, schedule.epoch_for(schedule.first_slot_in_epoch(epoch)) }
    end
  end
end
