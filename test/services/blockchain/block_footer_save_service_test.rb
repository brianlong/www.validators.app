# frozen_string_literal: true

require "test_helper"
require "geyser_pb"

module Blockchain
  class BlockFooterSaveServiceTest < ActiveSupport::TestCase
    setup do
      @network = "alpenglow-community"
      @epoch_schedule = Blockchain::EpochSchedule.new(
        "slotsPerEpoch" => 54_000, "firstNormalEpoch" => 0, "firstNormalSlot" => 0
      )
      @leader_schedule = Struct.new(:leaders) do
        def leader_for(slot)
          leaders[slot]
        end
      end.new({ 10_007_782 => "LeaderIdentity" })
      @footers = JSON.parse(file_fixture("alpenglow_footers.json").read).transform_values do |data|
        Blockchain::BlockFooterDecoder.new(
          Geyser::SubscribeUpdateBlockFooter.new(
            slot: data["slot"],
            bank_id: 7,
            bank_hash: "\xAB".b * 32,
            block_producer_time_nanos: data["block_producer_time_nanos"],
            block_user_agent: data["block_user_agent"].b,
            block_final_cert: hex_or_nil(data["block_final_cert"]),
            notar_reward_cert: hex_or_nil(data["notar_reward_cert"]),
            skip_reward_cert: hex_or_nil(data["skip_reward_cert"])
          )
        ).call
      end
    end

    def hex_or_nil(hex)
      hex.empty? ? nil : [hex].pack("H*")
    end

    def save(footers)
      Blockchain::BlockFooterSaveService.new(
        network: @network,
        footers: footers,
        epoch_schedule: @epoch_schedule,
        leader_schedule: @leader_schedule
      ).call
    end

    test "#call saves decoded footers" do
      assert_equal 3, save(@footers.values)

      footer = Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 10_007_782)
      assert_equal 185, footer.epoch
      assert_equal "LeaderIdentity", footer.leader
      assert_equal 7, footer.bank_id
      assert_equal "\xAB".b * 32, footer.bank_hash
      assert_equal "agave/4.3.0-rc.1 (src:84ce33bb; feat:c9ad34d2, client:JitoLabs)", footer.block_user_agent
      assert footer.slow?
      assert_equal 10_007_780, footer.final_cert_slot
      assert_equal 10_007_774, footer.notar_reward_slot
      assert_nil footer.skip_reward_slot
      assert_nil footer.skip_reward_signers
      refute footer.processed
    end

    test "#call stores raw signer bitmaps from the decoder" do
      save(@footers.values)

      footer = Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 10_007_782)
      decoded = @footers["slow"]

      assert_equal decoded[:block_final_cert][:final_signers], footer.final_signers
      assert_equal decoded[:block_final_cert][:notar_signers], footer.final_notar_signers
      assert_equal decoded[:notar_reward_cert][:signers], footer.notar_reward_signers
      assert_equal 65, Blockchain::SignerStore.decode(footer.final_signers)[:ranks].size
    end

    test "#call saves fast finalization and skip reward" do
      save(@footers.values)

      footer = Blockchain::AlpenglowCommunityBlockFooter.find_by(slot_number: 10_007_807)
      assert footer.fast?
      assert_nil footer.final_notar_signers
      assert_equal 10_007_799, footer.skip_reward_slot
      assert_equal [81], Blockchain::SignerStore.decode(footer.skip_reward_signers)[:ranks]
    end

    test "#call upserts footers for already saved slots without resetting processed" do
      save([@footers["fast"]])
      Blockchain::AlpenglowCommunityBlockFooter.update_all(processed: true)

      replacement = @footers["fast"].merge(block_user_agent: "replacement")
      save([replacement, @footers["fast"].merge(block_user_agent: "replacement 2")])

      assert_equal 1, Blockchain::AlpenglowCommunityBlockFooter.count
      footer = Blockchain::AlpenglowCommunityBlockFooter.last
      assert_equal "replacement 2", footer.block_user_agent
      assert footer.processed
    end

    test "#call saves nil leader when schedule is unknown" do
      save([@footers["fast"]])

      assert_nil Blockchain::AlpenglowCommunityBlockFooter.last.leader
    end

    test "#call truncates long user agents" do
      save([@footers["fast"].merge(block_user_agent: "a" * 300)])

      assert_equal 191, Blockchain::AlpenglowCommunityBlockFooter.last.block_user_agent.size
    end

    test "#call returns 0 for empty batch" do
      assert_equal 0, save([])
    end

    test ".network raises for networks without block footers" do
      assert_raises(ArgumentError) { Blockchain::BlockFooter.network("mainnet") }
    end
  end
end
