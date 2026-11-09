# frozen_string_literal: true

require "test_helper"

module XNotifications
  class DelinquencyServiceTest < ActiveSupport::TestCase
    setup do
      @validator = create(:validator, :mainnet, name: "Gotas")
      @score = create(
        :validator_score_v1,
        validator: @validator,
        network: "mainnet",
        delinquent: true,
        active_stake: 139_700 * 1_000_000_000
      )
    end

    def create_history(delinquent:, created_at:)
      create(
        :validator_history,
        validator: @validator,
        account: @validator.account,
        network: "mainnet",
        delinquent: delinquent,
        created_at: created_at
      )
    end

    test "posts delinquency started after min minutes" do
      create_history(delinquent: false, created_at: 17.minutes.ago)
      create_history(delinquent: true, created_at: 16.minutes.ago)

      DelinquencyService.new(network: "mainnet").call

      x_post = XPost.find_by(kind: "delinquency_started")
      assert_equal @validator, x_post.validator
      assert_equal "Gotas has stopped voting. Delinquent for 16 minutes with 139.7K SOL delegated.", x_post.message
    end

    test "does not post when validator is delinquent shorter than min minutes" do
      create_history(delinquent: false, created_at: 6.minutes.ago)
      create_history(delinquent: true, created_at: 5.minutes.ago)

      DelinquencyService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end

    test "does not post when stake is below threshold" do
      @score.update!(active_stake: 1_000 * 1_000_000_000)
      create_history(delinquent: false, created_at: 30.minutes.ago)
      create_history(delinquent: true, created_at: 20.minutes.ago)

      DelinquencyService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end

    test "does not post incidents older than max age" do
      create_history(delinquent: false, created_at: 3.days.ago)
      create_history(delinquent: true, created_at: 3.days.ago + 1.minute)

      DelinquencyService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end

    test "posts started only once per incident" do
      create_history(delinquent: false, created_at: 30.minutes.ago)
      create_history(delinquent: true, created_at: 20.minutes.ago)

      2.times { DelinquencyService.new(network: "mainnet").call }

      assert_equal 1, XPost.where(kind: "delinquency_started").count
    end

    test "posts resolved as reply when validator votes again" do
      create_history(delinquent: false, created_at: 80.minutes.ago)
      create_history(delinquent: true, created_at: 72.minutes.ago)
      DelinquencyService.new(network: "mainnet").call

      @score.update!(delinquent: false)
      2.times { DelinquencyService.new(network: "mainnet").call }

      started = XPost.find_by(kind: "delinquency_started")
      resolved = XPost.where(kind: "delinquency_resolved")
      assert_equal 1, resolved.count
      assert_equal started, resolved.first.parent
      assert_equal "Gotas is voting again after 1h 12m.", resolved.first.message
    end

    test "shortens account when validator has no name" do
      @validator.update!(name: nil, account: "GLCrAbCdEfGhgSZX")
      create_history(delinquent: false, created_at: 30.minutes.ago)
      create_history(delinquent: true, created_at: 20.minutes.ago)

      DelinquencyService.new(network: "mainnet").call

      assert XPost.last.message.start_with?("GLCr…gSZX has stopped voting.")
    end
  end
end
