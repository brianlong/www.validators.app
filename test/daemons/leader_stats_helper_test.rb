# frozen_string_literal: true

require "test_helper"
require Rails.root.join("daemons", "concerns", "leader_stats_helper")

class LeaderStatsHelperTest < ActiveSupport::TestCase
  include LeaderStatsHelper
  include VcrHelper

  setup do
    @test_accounts = [
      "9MRUTN19MtA1matBH4ddgpS14mPAdeCoFnsLkaLxFeBQ",
      "ACPgwKgncgFAm8goFj4dJ5e5mcH3tRy646f7zYPaWEzc",
      "FbWq9mwUQRNVCAUdcECF5yhdwABmcnsZ6a6zpixeKuQE"
    ]

    @validator = create(:validator, network: "testnet")
    @test_accounts.each do |account|
      create(:validator, network: "testnet", account: account)
    end
    @vcr_namespace ||= File.join("daemons", "leader_stats_helper_test")
  end

  test "#all_leaders returns data for both networks" do
    vcr_cassette(@vcr_namespace, __method__) do
      result = all_leaders
      assert result.keys.include? "mainnet"
      assert result.keys.include? "testnet"
    end
  end

  test "#leaders_for_network returns correct leaders" do
    vcr_cassette(@vcr_namespace, __method__) do
      result = all_leaders

      assert_equal @test_accounts[0], result["testnet"][:current_leader]["account"]
      assert_equal @test_accounts[1], result["testnet"][:next_leaders].first["account"]
      assert_equal @test_accounts[2], result["testnet"][:next_leaders].second["account"]
    end
  end
end
