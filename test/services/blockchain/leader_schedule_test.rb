# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

module Blockchain
  class LeaderScheduleTest < ActiveSupport::TestCase
    setup do
      @rpc_url = "https://alpenglow.example.com/token"
      @epoch_schedule = Blockchain::EpochSchedule.new(
        "slotsPerEpoch" => 8, "firstNormalEpoch" => 0, "firstNormalSlot" => 0
      )
      @leader_schedule = Blockchain::LeaderSchedule.new(rpc_urls: [@rpc_url], epoch_schedule: @epoch_schedule)
    end

    def stub_leader_schedule(first_slot, result)
      stub_request(:post, @rpc_url)
        .with(body: hash_including("method" => "getLeaderSchedule", "params" => [first_slot]))
        .to_return(body: { jsonrpc: "2.0", id: 1, result: result }.to_json)
    end

    test "#leader_for returns the leader of a slot" do
      stub_leader_schedule(8, { "LeaderA" => [0, 1, 2, 3], "LeaderB" => [4, 5, 6, 7] })

      assert_equal "LeaderA", @leader_schedule.leader_for(8)
      assert_equal "LeaderA", @leader_schedule.leader_for(11)
      assert_equal "LeaderB", @leader_schedule.leader_for(12)
      assert_equal "LeaderB", @leader_schedule.leader_for(15)
    end

    test "#leader_for fetches each epoch schedule only once" do
      request = stub_leader_schedule(8, { "LeaderA" => (0..7).to_a })

      5.times { |i| @leader_schedule.leader_for(8 + i) }

      assert_requested request, times: 1
    end

    test "#leader_for fetches the next epoch schedule at epoch boundary" do
      stub_leader_schedule(8, { "LeaderA" => (0..7).to_a })
      stub_leader_schedule(16, { "LeaderB" => (0..7).to_a })

      assert_equal "LeaderA", @leader_schedule.leader_for(15)
      assert_equal "LeaderB", @leader_schedule.leader_for(16)
    end

    test "#leader_for returns nil and does not retry immediately when schedule is unavailable" do
      request = stub_leader_schedule(8, nil)

      assert_nil @leader_schedule.leader_for(8)
      assert_nil @leader_schedule.leader_for(9)
      assert_requested request, times: 1
    end
  end
end
