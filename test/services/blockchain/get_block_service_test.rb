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
        "parentSlot" => 12345,
        "transactions" => [
          {
            "meta"=>{
              "computeUnitsConsumed"=>2100,
              "err"=>nil, "fee"=>5000,
              "innerInstructions"=>[],
              "loadedAddresses"=>{
                "readonly"=>[],
                "writable"=>[]
              },
              "logMessages"=>[
                "Program Vote111111111111111111111111111111111111111 invoke [1]",
                "Program Vote111111111111111111111111111111111111111 success"
              ],
              "postBalances"=>[2254760266, 27074400, 1],
              "postTokenBalances"=>[],
              "preBalances"=>[2254765266, 27074400, 1],
              "preTokenBalances"=>[],
              "rewards"=>[],
              "status"=>{"Ok"=>nil}
            },
            "transaction"=>{
              "message"=>{
                "accountKeys"=>[
                  {"pubkey" => "CoreZU3NjoVQKcx7wTPty13BmQhrJUjhvS6Hdjq6nbYx", "signer" => true, "writable" => true},
                  {"pubkey" => "6DVFiYKvmPRvYjins4LtRSiEm81CswtP5yHTpgPdtrgK", "signer" => false, "writable" => true},
                  {"pubkey" => "Vote111111111111111111111111111111111111111", "signer" => false, "writable" => false}
                ],
                "header"=>{
                  "numReadonlySignedAccounts"=>0,
                  "numReadonlyUnsignedAccounts"=>1,
                  "numRequiredSignatures"=>1
                },
                "instructions"=>[{
                  "parsed" => {
                    "type" => "vote",
                    "info" => {
                      "voteAccount" => "6DVFiYKvmPRvYjins4LtRSiEm81CswtP5yHTpgPdtrgK",
                      "voteAuthority" => "CoreZU3NjoVQKcx7wTPty13BmQhrJUjhvS6Hdjq6nbYx",
                      "votes" => [
                        {"slot" => 12340, "confirmationCount" => 5},
                        {"slot" => 12341, "confirmationCount" => 4},
                        {"slot" => 12342, "confirmationCount" => 3}
                      ]
                    }
                  },
                  "program" => "vote",
                  "programId" => "Vote111111111111111111111111111111111111111"
                }],
                "recentBlockhash"=>"4W2iKcjsuTfxEzovgt3LfALUPGNxscFrhtjN4mVurw6L"
              },
              "signatures"=>["qwzarzbeRUVYA5F9ia2Jcas7PJD2s9dM9Gj59EfQSBeUEPNymMRLGPVPmnF1ZooeXaK2wrMD7uThvHW6RgzqDQj"]
            },
            "version"=>"legacy"
          }
        ]
      }

      @slot = create(:testnet_slot, slot_number: @slot_number)
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

      Blockchain::GetBlockService.new(@network, @slot_number, @config_urls).update_slot_status(status: "has_block")
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

    test "#process_transactions creates new blockchain::transaction" do
      block_service = Blockchain::GetBlockService.new(@network, @slot_number, @config_urls)
      block_service.stub(:solana_client_request, @block) do
        block_service.call
      end

      assert_equal 1, Blockchain::Transaction.count
      transaction = Blockchain::Transaction.network(@network).last
      assert_equal "CoreZU3NjoVQKcx7wTPty13BmQhrJUjhvS6Hdjq6nbYx", transaction.account_key_1
      assert_equal "6DVFiYKvmPRvYjins4LtRSiEm81CswtP5yHTpgPdtrgK", transaction.account_key_2
      assert_equal "Vote111111111111111111111111111111111111111", transaction.account_key_3
      assert_equal 5000, transaction.fee
      assert_equal [2254765266, 27074400, 1], transaction.pre_balances
      assert_equal [2254760266, 27074400, 1], transaction.post_balances
      assert_equal "12342", transaction.recent_blockhash  # voted_slot stored as string
      assert_equal Blockchain::Block.network(@network).last.id, transaction.block_id
    end

    test "#process_transactions does not create new blockchain::transaction when no vote transactions" do
      @block["transactions"][0]["transaction"]["message"]["accountKeys"][2]["pubkey"] = "Vote111111111111111111111111111111111111112"
      block_service = Blockchain::GetBlockService.new(@network, @slot_number, @config_urls)
      block_service.stub(:solana_client_request, @block) do
        block_service.call
      end
      assert_equal 0, Blockchain::Transaction.count
    end
  end
end
