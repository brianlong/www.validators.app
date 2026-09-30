# frozen_string_literal: true

require "test_helper"
require "geyser_pb"

module Blockchain
  class AlpenglowFooterDecoderTest < ActiveSupport::TestCase
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
      Blockchain::AlpenglowFooterDecoder.new(build_footer(@footers[name])).call
    end

    test "#call decodes footer metadata" do
      result = decode("fast")

      assert_equal 10_007_788, result[:slot]
      assert_equal 1, result[:bank_id]
      assert_equal "01" * 32, result[:bank_hash]
      assert_equal @footers["fast"]["block_producer_time_nanos"], result[:block_producer_time_nanos]
      assert_equal "agave/4.3.0-rc.1 (src:f09566a9; feat:c9ad34d2, client:HarmonicAgave)", result[:block_user_agent]
      assert_equal Encoding::UTF_8, result[:block_user_agent].encoding
    end

    test "#call decodes fast finalization certificate" do
      cert = decode("fast")[:block_final_cert]

      assert_equal 10_007_787, cert[:slot]
      assert_equal "fast", cert[:finalization]
      assert_equal 64, cert[:block_id].size
      assert_nil cert[:notar_aggregate]
      assert_equal 104, cert[:final_aggregate][:bitmap_length]
      assert_equal 83, cert[:final_aggregate][:ranks].size
      assert_equal [1, 2, 3, 4, 5], cert[:final_aggregate][:ranks].first(5)
    end

    test "#call decodes slow finalization certificate with notar aggregate" do
      cert = decode("slow")[:block_final_cert]

      assert_equal 10_007_780, cert[:slot]
      assert_equal "slow", cert[:finalization]
      assert_equal 65, cert[:final_aggregate][:ranks].size
      assert_equal 58, cert[:notar_aggregate][:ranks].size
    end

    test "#call decodes notar reward certificate" do
      cert = decode("fast")[:notar_reward_cert]

      assert_equal 10_007_780, cert[:slot]
      assert_equal 104, cert[:bitmap_length]
      assert_equal 87, cert[:ranks].size
      assert_equal [0, 20, 26, 27, 28, 29, 30, 32, 78, 90, 92, 95, 96, 97, 98, 99, 101], (0...104).to_a - cert[:ranks]
    end

    test "#call decodes skip reward certificate" do
      result = decode("skip")

      assert_equal({ slot: 10_007_799, bitmap_length: 82, ranks: [81] }, result[:skip_reward_cert].except(:signers))
      refute_includes result[:notar_reward_cert][:ranks], 81
    end

    test "#call returns raw signer bytes that decode back to the same ranks" do
      cert = decode("slow")[:block_final_cert]
      signers = cert[:notar_aggregate][:signers]

      assert_equal Encoding::ASCII_8BIT, signers.encoding
      assert_equal cert[:notar_aggregate].except(:signers), Blockchain::AlpenglowFooterDecoder.decode_signers(signers)
    end

    test "#call returns nil for missing certificates" do
      result = decode("slow")

      assert_nil result[:skip_reward_cert]
      assert_nil Blockchain::AlpenglowFooterDecoder.new(
        Geyser::SubscribeUpdateBlockFooter.new(slot: 1)
      ).call[:block_final_cert]
    end

    test "#call decodes base3 signer store" do
      bitmap = [1, 5].pack("CS<") + [1 + 2 * 3 + 0 * 9 + 1 * 27 + 2 * 81].pack("C")
      skip_cert = [10].pack("Q<") + ("\x00".b * 96) + [bitmap.bytesize].pack("C") + bitmap
      footer = Geyser::SubscribeUpdateBlockFooter.new(slot: 11, skip_reward_cert: skip_cert)

      result = Blockchain::AlpenglowFooterDecoder.new(footer).call[:skip_reward_cert]

      assert_equal [0, 3], result[:ranks]
      assert_equal [1, 4], result[:fallback_ranks]
    end

    test "#call raises DecodeError for truncated certificate" do
      data = @footers["fast"].merge("block_final_cert" => @footers["fast"]["block_final_cert"][0...-10])

      assert_raises(Blockchain::AlpenglowFooterDecoder::DecodeError) do
        Blockchain::AlpenglowFooterDecoder.new(build_footer(data)).call
      end
    end
  end
end
