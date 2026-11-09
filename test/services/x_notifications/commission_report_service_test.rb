# frozen_string_literal: true

require "test_helper"

module XNotifications
  class CommissionReportServiceTest < ActiveSupport::TestCase
    setup do
      create(:epoch_wall_clock, network: "mainnet", epoch: 1076, created_at: 3.hours.ago)
      @validator = create(:validator, :mainnet, name: "BlackMont")
      create(:validator_score_v1, validator: @validator, network: "mainnet", active_stake: 35_700 * 1_000_000_000)
    end

    test "posts report with commission increases from previous epoch" do
      create(:commission_history, validator: @validator, network: "mainnet", epoch: 1075, commission_before: 0, commission_after: 100)
      create(:commission_history, validator: @validator, network: "mainnet", epoch: 1075, commission_before: 100, commission_after: 0)

      CommissionReportService.new(network: "mainnet").call

      x_post = XPost.find_by(kind: "commission_epoch_report")
      assert_equal "commission_epoch_report:mainnet:1075", x_post.reference_key
      expected = "Epoch 1075 commission report\n\n1 commission increase: BlackMont 0% → 100%. 35.7K SOL delegated to them."
      assert_equal expected, x_post.message
    end

    test "ignores increases below threshold and other epochs" do
      create(:commission_history, validator: @validator, network: "mainnet", epoch: 1075, commission_before: 5, commission_after: 7)
      create(:commission_history, validator: @validator, network: "mainnet", epoch: 1076, commission_before: 0, commission_after: 100)

      CommissionReportService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end

    test "waits until epoch report delay passes" do
      EpochWallClock.update_all(created_at: 30.minutes.ago)
      create(:commission_history, validator: @validator, network: "mainnet", epoch: 1075, commission_before: 0, commission_after: 100)

      CommissionReportService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end

    test "fits many validators within post length" do
      20.times do |i|
        validator = create(:validator, :mainnet, name: "Validator with a long name #{i}")
        create(:validator_score_v1, validator: validator, network: "mainnet")
        create(:commission_history, validator: validator, network: "mainnet", epoch: 1075, commission_before: 0, commission_after: 100)
      end

      CommissionReportService.new(network: "mainnet").call

      message = XPost.last.message
      assert message.length <= X_POST_MAX_LENGTH
      assert_match(/and \d+ more\. .* SOL delegated to them\.\z/, message)
    end
  end
end
