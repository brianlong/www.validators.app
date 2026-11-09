# frozen_string_literal: true

require "test_helper"

module XNotifications
  class StakePoolReportServiceTest < ActiveSupport::TestCase
    LAMPORTS = 1_000_000_000

    setup do
      @pool = create(:stake_pool, name: "Jito", network: "mainnet")
      @validator_a = create(:validator, :mainnet)
      @validator_b = create(:validator, :mainnet)
      @validator_c = create(:validator, :mainnet)
    end

    def create_current(pubkey, validator, sol, deactivation_epoch: nil)
      create(
        :stake_account,
        stake_pubkey: pubkey,
        network: "mainnet",
        epoch: 1076,
        stake_pool_id: @pool.id,
        validator_id: validator.id,
        delegated_stake: sol * LAMPORTS,
        deactivation_epoch: deactivation_epoch
      )
    end

    def create_previous(pubkey, validator, sol)
      create(
        :stake_account_history,
        stake_pubkey: pubkey,
        network: "mainnet",
        epoch: 1075,
        stake_pool_id: @pool.id,
        validator_id: validator.id,
        delegated_stake: sol * LAMPORTS,
        deactivation_epoch: nil
      )
    end

    test "posts stake moved by pools between epochs" do
      create_previous("a1", @validator_a, 100_000)
      create_previous("a1", @validator_a, 100_000)
      create_previous("b1", @validator_b, 50_000)
      create_current("a1", @validator_a, 100_000, deactivation_epoch: 1076)
      create_current("b1", @validator_b, 50_000)
      create_current("c1", @validator_c, 30_000)
      create_current("c2", @validator_c, 1_000)

      StakePoolReportService.new(network: "mainnet").call

      x_post = XPost.find_by(kind: "stake_pool_epoch_report")
      assert_equal "stake_pool_epoch_report:mainnet:1076", x_post.reference_key
      assert_equal "Epoch 1076 stake pool report\n\nJito: +31.0K SOL to 1 validator, −100.0K SOL from 1 validator", x_post.message
    end

    test "does not post when changes are below threshold" do
      create_previous("a1", @validator_a, 100_000)
      create_current("a1", @validator_a, 105_000)

      StakePoolReportService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end

    test "does not post without previous epoch history" do
      create_current("a1", @validator_a, 100_000)

      StakePoolReportService.new(network: "mainnet").call

      assert_equal 0, XPost.count
    end
  end
end
