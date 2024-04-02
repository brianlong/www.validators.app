#frozen_string_literal: true

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
          {"slot": "123", "leader": "validator_account_1"},
          {"slot": "124", "leader": "validator_account_2"},
          {"slot": "125", "leader": "validator_account_3"},
          {"slot": "126", "leader": "validator_account_4"}
        ]
      }.to_json
    end

    test "#call downloads and saves current leader slots" do
      SolanaCliService.stub(:request, @json_data, ["leader-schedule --epoch #{@epoch}", @mainnet_url]) do
        Blockchain::GetLeaderScheduleService.new(@network, @epoch, [@mainnet_url]).call

        assert_equal 4, Blockchain::Slot.count
        assert_equal "validator_account_4", Blockchain::Slot.last.leader
        assert_equal 126, Blockchain::Slot.last.slot_number
        assert_equal @network, Blockchain::Slot.last.network
        assert_equal @epoch, Blockchain::Slot.last.epoch
        assert_equal "initialized", Blockchain::Slot.last.status
      end
    end

    test "#call does not create new slots when there already are some slots for this epoch" do
      existing_slot = create(:blockchain_slot)

      SolanaCliService.stub(:request, @json_data, ["leader-schedule --epoch #{@epoch}", @mainnet_url]) do
        Blockchain::GetLeaderScheduleService.new(@network, @epoch, [@mainnet_url]).call

        assert_equal 1, Blockchain::Slot.count
        assert_equal existing_slot, Blockchain::Slot.last
      end
    end
  end
end
