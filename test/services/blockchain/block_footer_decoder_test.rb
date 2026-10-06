# frozen_string_literal: true

require "test_helper"
require "geyser_pb"

module Blockchain
  class BlockFooterDecoderTest < ActiveSupport::TestCase
    setup do
      @footers = JSON.parse(file_fixture("alpenglow_footers.json").read)
    end

    def build_footer(data)
      Geyser::SubscribeUpdateBlockFooter.new(
        slot: data["slot"],
        bank_id: 1,
        bank_hash: "\x01".b * 32,
        block_producer_time_nanos: data["block_producer_time_nanos"],
        block_user_agent: data["block_user_agent"].b,
        block_final_cert: hex_or_nil(data["block_final_cert"]),
        notar_reward_cert: hex_or_nil(data["notar_reward_cert"]),
        skip_reward_cert: hex_or_nil(data["skip_reward_cert"])
      )
    end

    def hex_or_nil(hex)
      hex.empty? ? nil : [hex].pack("H*")
    end

    def decode(name)
      Blockchain::BlockFooterDecoder.new(build_footer(@footers[name])).call
    end

    def ranks(bytes)
      Blockchain::SignerStore.decode(bytes)[:ranks]
    end

    test "#call decodes footer metadata" do
      result = decode("fast")

      assert_equal 10_007_788, result[:slot]
      assert_equal 1, result[:bank_id]
      assert_equal "\x01".b * 32, result[:bank_hash]
      assert_equal @footers["fast"]["block_producer_time_nanos"], result[:block_producer_time_nanos]
      assert_equal "agave/4.3.0-rc.1 (src:f09566a9; feat:c9ad34d2, client:HarmonicAgave)", result[:block_user_agent]
      assert_equal Encoding::UTF_8, result[:block_user_agent].encoding
    end

    test "#call decodes fast finalization certificate" do
      cert = decode("fast")[:block_final_cert]

      assert_equal 10_007_787, cert[:slot]
      assert_equal "fast", cert[:finalization]
      assert_equal 64, cert[:block_id].size
      assert_nil cert[:notar_signers]
      assert_equal Encoding::ASCII_8BIT, cert[:final_signers].encoding
      assert_equal 83, ranks(cert[:final_signers]).size
      assert_equal [1, 2, 3, 4, 5], ranks(cert[:final_signers]).first(5)
    end

    test "#call decodes slow finalization certificate with notar signers" do
      cert = decode("slow")[:block_final_cert]

      assert_equal 10_007_780, cert[:slot]
      assert_equal "slow", cert[:finalization]
      assert_equal 65, ranks(cert[:final_signers]).size
      assert_equal 58, ranks(cert[:notar_signers]).size
    end

    test "#call decodes notar reward certificate" do
      cert = decode("fast")[:notar_reward_cert]

      assert_equal 10_007_780, cert[:slot]
      assert_equal 104, Blockchain::SignerStore.decode(cert[:signers])[:bitmap_length]
      assert_equal [0, 20, 26, 27, 28, 29, 30, 32, 78, 90, 92, 95, 96, 97, 98, 99, 101], (0...104).to_a - ranks(cert[:signers])
    end

    test "#call decodes skip reward certificate" do
      result = decode("skip")

      assert_equal 10_007_799, result[:skip_reward_cert][:slot]
      assert_equal [81], ranks(result[:skip_reward_cert][:signers])
      refute_includes ranks(result[:notar_reward_cert][:signers]), 81
    end

    test "#call returns nil for missing certificates" do
      result = decode("slow")

      assert_nil result[:skip_reward_cert]
      assert_nil Blockchain::BlockFooterDecoder.new(
        Geyser::SubscribeUpdateBlockFooter.new(slot: 1)
      ).call[:block_final_cert]
    end

    test "#call raises DecodeError for truncated certificate" do
      data = @footers["fast"].merge("block_final_cert" => @footers["fast"]["block_final_cert"][0...-10])

      assert_raises(Blockchain::BlockFooterDecoder::DecodeError) do
        Blockchain::BlockFooterDecoder.new(build_footer(data)).call
      end
    end

    test "#call raises DecodeError for invalid signer bitmap" do
      skip_cert = [10].pack("Q<") + ("\x00".b * 96) + [4].pack("C") + [9, 8].pack("CS<") + "\x00".b
      footer = Geyser::SubscribeUpdateBlockFooter.new(slot: 11, skip_reward_cert: skip_cert)

      assert_raises(Blockchain::BlockFooterDecoder::DecodeError) do
        Blockchain::BlockFooterDecoder.new(footer).call
      end
    end
  end
end
