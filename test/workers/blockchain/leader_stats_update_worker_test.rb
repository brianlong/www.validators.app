# frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"

class Blockchain::LeaderStatsUpdateWorkerTest < ActiveSupport::TestCase
  include VcrHelper
  include ActionCable::TestHelper

  setup do
    @test_accounts = [
      "9MRUTN19MtA1matBH4ddgpS14mPAdeCoFnsLkaLxFeBQ",
      "ACPgwKgncgFAm8goFj4dJ5e5mcH3tRy646f7zYPaWEzc",
      "FbWq9mwUQRNVCAUdcECF5yhdwABmcnsZ6a6zpixeKuQE"
    ]

    @test_accounts.each { |account| create(:validator, network: "testnet", account: account) }
    @vcr_namespace = File.join("workers", "blockchain", "leader_stats_update_worker_test")
  end

  test "perform broadcasts leaders for the network" do
    vcr_cassette(@vcr_namespace, __method__) do
      Sidekiq::Testing.inline! do
        assert_broadcasts("leaders_channel", 1) do
          Blockchain::LeaderStatsUpdateWorker.perform_async({"network" => "testnet", "slot_number" => rand(1_000_000)})
        end
      end
    end
  end
end
