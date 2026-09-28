# frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"

module Blockchain
  class SlotSubscribeServiceTest < ActiveSupport::TestCase
    setup do
      Sidekiq::Testing.fake!
      Sidekiq::Worker.clear_all
      SidekiqUniqueJobs::Digests.new.delete_by_pattern("*")
    end

    teardown do
      Sidekiq::Worker.clear_all
      SidekiqUniqueJobs::Digests.new.delete_by_pattern("*")
    end

    test "#handle_slot enqueues block fetching and leader stats by default" do
      SlotSubscribeService.new(network: "mainnet", rpc_url: "http://127.0.0.1").handle_slot(123)

      assert_equal 1, GetBlockWorker.jobs.size
      assert_equal "blockchain_mainnet", GetBlockWorker.jobs.first["queue"]
      assert_equal [{ "network" => "mainnet", "slot_number" => 123 }], GetBlockWorker.jobs.first["args"]
      assert_equal 1, LeaderStatsUpdateWorker.jobs.size
    end

    test "#handle_slot enqueues only leader stats when fetch_blocks is false" do
      SlotSubscribeService.new(network: "testnet", rpc_url: "http://127.0.0.1", fetch_blocks: false).handle_slot(123)

      assert_equal 0, GetBlockWorker.jobs.size
      assert_equal 1, LeaderStatsUpdateWorker.jobs.size
      assert_equal "blockchain_testnet", LeaderStatsUpdateWorker.jobs.first["queue"]
      assert_equal [{ "network" => "testnet", "slot_number" => 123 }], LeaderStatsUpdateWorker.jobs.first["args"]
    end

    test "#handle_slot skips block fetching on stage" do
      Rails.env.stub(:stage?, true) do
        SlotSubscribeService.new(network: "mainnet", rpc_url: "http://127.0.0.1").handle_slot(123)
      end

      assert_equal 0, GetBlockWorker.jobs.size
      assert_equal 1, LeaderStatsUpdateWorker.jobs.size
    end
  end
end
