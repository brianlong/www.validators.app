require "test_helper"
require Rails.root.join("daemons", "concerns", "leader_stats_helper")

class LeaderStatsHelperTest < ActiveSupport::TestCase
  include LeaderStatsHelper
  include VcrHelper

  setup do
    @validator = create(:validator, network: "testnet")
    ["9MRUTN19MtA1matBH4ddgpS14mPAdeCoFnsLkaLxFeBQ", "ACPgwKgncgFAm8goFj4dJ5e5mcH3tRy646f7zYPaWEzc", "FbWq9mwUQRNVCAUdcECF5yhdwABmcnsZ6a6zpixeKuQE"].each do |account|
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

      assert_equal "9MRUTN19MtA1matBH4ddgpS14mPAdeCoFnsLkaLxFeBQ", result["testnet"][:current_leader][:account]
      assert_equal "ACPgwKgncgFAm8goFj4dJ5e5mcH3tRy646f7zYPaWEzc", result["testnet"][:next_leaders].first[:account]
      assert_equal "FbWq9mwUQRNVCAUdcECF5yhdwABmcnsZ6a6zpixeKuQE", result["testnet"][:next_leaders].second[:account]
    end
  end
end
