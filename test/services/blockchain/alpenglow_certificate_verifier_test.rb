# frozen_string_literal: true

require "test_helper"

module Blockchain
  class AlpenglowCertificateVerifierTest < ActiveSupport::TestCase
    setup do
      @fixture = JSON.parse(file_fixture("alpenglow_certificates.json").read)
      @network = @fixture["network"]
      @certificates = @fixture["certificates"]
      create_ranks(@fixture["bls_pubkeys"])
    end

    def create_ranks(bls_pubkeys, status: :finalized)
      bls_pubkeys.each_with_index do |bls_pubkey, rank|
        AlpenglowEpochRank.create!(
          network: @network, epoch: @fixture["epoch"], rank: rank, vote_account: "Vote#{rank}",
          validator_identity: "Node#{rank}", bls_pubkey: bls_pubkey, stake: 1_000 - rank, status: status
        )
      end
    end

    def verifier
      Blockchain::AlpenglowCertificateVerifier.new(
        network: @network,
        epoch_schedule: Blockchain::EpochSchedule.new(@fixture["epoch_schedule"]),
        shred_version: @fixture["shred_version"]
      )
    end

    def certificate(type)
      @certificates.find { |certificate| certificate["type"] == type }
    end

    test "#call accepts certificates signed by validators in the epoch rank order" do
      results = verifier.call(@certificates)

      assert_equal %w[slow_finalize slow_notarize fast notar_reward], results.map { |result| result[:type] }
      assert(results.all? { |result| result[:valid] })
      assert_equal [238], results.map { |result| result[:epoch] }.uniq
      assert_equal 82, results.find { |result| result[:type] == "fast" }[:signers]
    end

    test "#call rejects certificates when ranks are in a different order" do
      AlpenglowEpochRank.delete_all
      signers = Blockchain::SignerStore.decode([certificate("fast")["signers"]].pack("H*"))[:ranks]
      signer = signers.first
      non_signer = ((0...@fixture["bls_pubkeys"].size).to_a - signers).first
      keys = @fixture["bls_pubkeys"].dup
      keys[signer], keys[non_signer] = keys[non_signer], keys[signer]
      create_ranks(keys)

      refute verifier.call([certificate("fast")]).first[:valid]
    end

    test "#call rejects a tampered signature" do
      tampered = certificate("fast").merge("signature" => certificate("notar_reward")["signature"])

      refute verifier.call([tampered]).first[:valid]
    end

    test "#call rejects a certificate signed for a different vote type" do
      wrong_type = certificate("slow_finalize").merge("type" => "skip_reward")

      refute verifier.call([wrong_type]).first[:valid]
    end

    test "#call rejects a certificate for a different shred version" do
      other_cluster = Blockchain::AlpenglowCertificateVerifier.new(
        network: @network,
        epoch_schedule: Blockchain::EpochSchedule.new(@fixture["epoch_schedule"]),
        shred_version: 4457
      )

      refute other_cluster.call([certificate("fast")]).first[:valid]
    end

    test "#call rejects signers outside of the rank map" do
      AlpenglowEpochRank.where("`rank` >= 50").delete_all

      refute verifier.call([certificate("fast")]).first[:valid]
    end

    test "#call skips certificates without finalized ranks" do
      AlpenglowEpochRank.update_all(status: AlpenglowEpochRank.statuses[:provisional])

      assert_empty verifier.call(@certificates)
    end

    test "#call skips certificates of epochs with rejected ranks" do
      AlpenglowEpochRank.update_all(status: AlpenglowEpochRank.statuses[:rejected])

      assert_empty verifier.call(@certificates)
    end

    test "#call keeps checking epochs with verified ranks" do
      AlpenglowEpochRank.update_all(status: AlpenglowEpochRank.statuses[:verified])

      assert_equal 4, verifier.call(@certificates).count { |result| result[:valid] }
    end

    test ".certificates_from_footer builds slow finalization certificates" do
      footer = {
        block_final_cert: {
          slot: 5, block_id: "ab" * 32, final_signature: "\x01".b * 96, final_signers: "\x00\x01\x00\x01".b,
          notar_signature: "\x02".b * 96, notar_signers: "\x00\x02\x00\x03".b
        },
        skip_reward_cert: { slot: 4, signature: "\x03".b * 96, signers: "\x00\x01\x00\x01".b }
      }

      certificates = Blockchain::AlpenglowCertificateVerifier.certificates_from_footer(footer)

      assert_equal %w[slow_finalize slow_notarize skip_reward], certificates.map { |c| c["type"] }
      assert_equal ["ab" * 32, nil], [certificates[1]["block_id"], certificates[2]["block_id"]]
      assert_equal ["02" * 96, "00020003"], certificates[1].values_at("signature", "signers")
    end

    test ".certificates_from_footer builds fast and notar reward certificates" do
      footer = {
        block_final_cert: { slot: 5, block_id: "ab" * 32, final_signature: "\x01".b * 96, final_signers: "\x00\x01\x00\x01".b },
        notar_reward_cert: { slot: 3, block_id: "cd" * 32, signature: "\x04".b * 96, signers: "\x00\x01\x00\x01".b }
      }

      certificates = Blockchain::AlpenglowCertificateVerifier.certificates_from_footer(footer)

      assert_equal [%w[fast 5], %w[notar_reward 3]], certificates.map { |c| [c["type"], c["slot"].to_s] }
    end
  end
end
