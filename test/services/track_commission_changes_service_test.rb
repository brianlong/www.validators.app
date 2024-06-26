# frozen_string_literal: true

require "test_helper"

class TrackCommissionChangesServiceTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @network = "mainnet"
    @namespace = File.join("services", "track_commission_changes_service")
    @solana_url = "https://api.mainnet-beta.solana.com"
    @current_batch = create(:batch, :mainnet, scored_at: DateTime.now)
    create(:batch, :mainnet, scored_at: 1.day.ago, created_at: 1.day.ago - 5.minutes)
    create(
      :epoch_wall_clock,
      epoch: 400,
      network: @network,
      starting_slot: 172800020,
      slots_in_epoch: 432000,
      created_at: "2023-01-16 14:02:26.000000000 +0000"
    )
    create(
      :epoch_wall_clock,
      epoch: 399,
      network: @network,
      starting_slot: 172368008,
      slots_in_epoch: 432000,
      created_at: "2023-01-14 01:49:21.000000000 +0000"
    )
    validator = create(:validator, network: "mainnet", account: "BPKAfGkkzF5u1QRjjB1nWYYbPMUCMPJe1xZPmwEMNMCT")
    @vote_acc = create(
      :vote_account,
      validator: validator,
      account: "9Gko8QZBbV5SrEvHKtQHcMrGGSfgFP3KJUozEGifu25x",
      is_active: true,
      network: @network
    )
  end

  test "#call creates new commission_histories" do
    vcr_cassette(@namespace, self.class.name.underscore) do
      assert_equal 0, CommissionHistory.count

      TrackCommissionChangesService.new(
        current_batch: @current_batch,
        network: @network,
        solana_url: [@solana_url]
      ).call

      assert_equal 2, CommissionHistory.count
      assert_equal 399, CommissionHistory.first.epoch
      assert_equal 400, CommissionHistory.last.epoch
    end
  end

  test "#call does not create previous_history if it's already in the epoch" do
    vcr_cassette(@namespace, self.class.name.underscore) do
      assert_equal 0, CommissionHistory.count
      create(
        :commission_history,
        epoch: 399,
        network: @network,
        validator: @vote_acc.validator,
        commission_before: 100,
        commission_after: 10,
        source_from_rewards: false
      )

      TrackCommissionChangesService.new(
        current_batch: @current_batch,
        network: @network,
        solana_url: [@solana_url]
      ).call

      assert_equal CommissionHistory.count, 2
      assert_equal 399, CommissionHistory.first.epoch
      assert_equal 400, CommissionHistory.last.epoch
    end
  end

  test "#call does not create previous_history if it's the same as last commission_history" do
    vcr_cassette(@namespace, self.class.name.underscore) do
      assert_equal 0, CommissionHistory.count
      create(
        :commission_history,
        epoch: 395,
        network: @network,
        validator: @vote_acc.validator,
        commission_before: 100,
        commission_after: 10,
        source_from_rewards: false
      )

      TrackCommissionChangesService.new(
        current_batch: @current_batch,
        network: @network,
        solana_url: [@solana_url]
      ).call

      assert_equal 2, CommissionHistory.count
      assert_equal 395, CommissionHistory.first.epoch
      assert_equal 400, CommissionHistory.last.epoch
    end
  end

  test "#call does not create new commission_histories when vote_account is not active" do
    @vote_acc.update(is_active: false)
    vcr_cassette(@namespace, __method__) do
      assert_equal CommissionHistory.count, 0

      TrackCommissionChangesService.new(
        current_batch: @current_batch,
        network: @network,
        solana_url: [@solana_url]
      ).call

      assert_equal CommissionHistory.count, 0

    end
  end

  test "#call does not create new commission_histories when there is no epoch from solana" do
    vcr_cassette(@namespace, self.class.name.underscore + "_no_epoch") do
      assert_equal CommissionHistory.count, 0

      TrackCommissionChangesService.new(
        current_batch: @current_batch,
        network: @network,
        solana_url: [@solana_url]
      ).call

      assert_equal CommissionHistory.count, 0

    end
  end
end
