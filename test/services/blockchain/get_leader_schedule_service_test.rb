# frozen_string_literal: true

require "test_helper"

module Blockchain
  class GetLeaderScheduleServiceTest < ActiveSupport::TestCase
    include VcrHelper

    setup do
      @epoch = 586
      @network = "mainnet"
      @mainnet_url = "https://api.mainnet-beta.solana.com"
      @json_data = {
        "epoch": 586,
        "leaderScheduleEntries": [
          { "slot": "123", "leader": "validator_account_1" },
          { "slot": "124", "leader": "validator_account_2" },
          { "slot": "125", "leader": "validator_account_3" },
          { "slot": "126", "leader": "validator_account_4" }
        ]
      }.to_json
    end

    test "#call downloads and saves current leader slots" do
      SolanaCliService.stub(:request, @json_data, ["leader-schedule --epoch #{@epoch}", @mainnet_url]) do
        Blockchain::GetLeaderScheduleService.new(@network, @epoch, [@mainnet_url]).call

        assert_equal 4, Blockchain::Slot.count
        assert_equal "validator_account_4", Blockchain::MainnetSlot.last.leader
        assert_equal 126, Blockchain::MainnetSlot.last.slot_number
        assert_equal @epoch, Blockchain::MainnetSlot.last.epoch
        assert_equal "initialized", Blockchain::MainnetSlot.last.status
      end
    end

    test "#call does not create new slots when there already are some slots for this epoch" do
      existing_slot = create(:mainnet_slot)

      SolanaCliService.stub(:request, @json_data, ["leader-schedule --epoch #{@epoch}", @mainnet_url]) do
        Blockchain::GetLeaderScheduleService.new(@network, @epoch, [@mainnet_url]).call

        assert_equal 1, Blockchain::MainnetSlot.count
        assert_equal existing_slot, Blockchain::MainnetSlot.last
      end
    end
  end
end
