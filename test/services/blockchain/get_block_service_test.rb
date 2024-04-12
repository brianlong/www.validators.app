#  frozen_string_literal: true

require "test_helper"

module Blockchain
  class GetBlockServiceTest < ActiveSupport::TestCase

    setup do
      @network = "testnet"
      @slot_number = 12345
      @config_urls = ["http://localhost:8900"]
      @block = {
        "blockHeight" => 123,
        "blockTime" => 12,
        "blockhash" => "block_hash_123",
        "parentSlot" => 12345
      }

      @slot = create(:blockchain_slot, network: @network, slot_number: @slot_number)
    end

    test "#call creates new blockchain::block" do
      block_service = Blockchain::GetBlockService.new(@network, @slot_number, @config_urls)
      block_service.stub(:solana_client_request, @block) do
        block_service.call
      end
      assert_equal 1, Blockchain::Block.count
      assert_equal "has_block", @slot.reload.status
    end

    test "#call updates slot status to request_error when error occurs" do
      block_service = Blockchain::GetBlockService.new(@network, @slot_number, @config_urls)
      block_service.stub(:solana_client_request, { error: "solana error" }) do
        block_service.call
      end
      assert_equal 0, Blockchain::Block.count
      assert_equal "request_error", @slot.reload.status
    end

    test "#update_slot_status updates slot status" do
      assert_equal "initialized", @slot.status

      Blockchain::GetBlockService.new(@network, @slot_number, @config_urls).update_slot_status
      assert_equal "has_block", @slot.reload.status

      Blockchain::GetBlockService.new(@network, @slot_number, @config_urls)
                                 .update_slot_status(status: "request_error")
      assert_equal "request_error", @slot.reload.status
    end

    test "#update_slot_status updates slot status to no_block when request_error" do
      @slot.update(status: "request_error")
      @slot.reload
      Blockchain::GetBlockService.new(@network, @slot_number, @config_urls)
                                 .update_slot_status(status: "request_error")
      assert_equal "no_block", @slot.reload.status
    end
  end
end
