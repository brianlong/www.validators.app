# frozen_string_literal: true

module Blockchain
  class AlpenglowCertificateVerifier
    NOTAR_VOTE = 1
    FINALIZE_VOTE = 2
    SKIP_VOTE = 3

    SIGNED_VOTES = {
      "fast" => NOTAR_VOTE,
      "slow_notarize" => NOTAR_VOTE,
      "notar_reward" => NOTAR_VOTE,
      "slow_finalize" => FINALIZE_VOTE,
      "skip_reward" => SKIP_VOTE
    }.freeze

    def self.certificates_from_footer(footer)
      final_certificates(footer[:block_final_cert]) + reward_certificates(footer[:notar_reward_cert], footer[:skip_reward_cert])
    end

    def self.final_certificates(cert)
      return [] unless cert
      return [certificate("fast", cert[:slot], cert[:block_id], cert[:final_signature], cert[:final_signers])] unless cert[:notar_signers]

      [
        certificate("slow_finalize", cert[:slot], nil, cert[:final_signature], cert[:final_signers]),
        certificate("slow_notarize", cert[:slot], cert[:block_id], cert[:notar_signature], cert[:notar_signers])
      ]
    end

    def self.reward_certificates(notar_reward, skip_reward)
      [
        notar_reward && certificate("notar_reward", *notar_reward.values_at(:slot, :block_id, :signature, :signers)),
        skip_reward && certificate("skip_reward", skip_reward[:slot], nil, skip_reward[:signature], skip_reward[:signers])
      ].compact
    end

    def self.certificate(type, slot, block_id, signature, signers)
      { "type" => type, "slot" => slot, "block_id" => block_id, "signature" => signature.unpack1("H*"), "signers" => signers.unpack1("H*") }
    end

    def self.shred_version(network)
      nodes = Blockchain::JsonRpcRequest.new(NETWORK_URLS[network]).call("getClusterNodes")
      raise "Cluster nodes unavailable for #{network}" if nodes.blank?

      nodes.map { |node| node["shredVersion"] }.compact.tally.max_by(&:last).first
    end

    def initialize(network:, epoch_schedule:, shred_version:)
      require "bls"
      @network = network
      @epoch_schedule = epoch_schedule
      @shred_version = shred_version
      @keys = {}
      @points = {}
    end

    def call(certificates)
      certificates.filter_map { |certificate| verify(certificate) }
    end

    private

    def verify(certificate)
      slot = certificate["slot"]
      epoch = @epoch_schedule.epoch_for(slot)
      keys = keys_for(epoch)
      return nil if keys.empty?

      decoded = Blockchain::SignerStore.decode([certificate["signers"]].pack("H*"))
      return nil if decoded[:fallback_ranks].present?

      result = { type: certificate["type"], slot: slot, epoch: epoch, signers: decoded[:ranks].size }
      result.merge(valid: valid_signature?(certificate, decoded[:ranks], keys))
    end

    def valid_signature?(certificate, ranks, keys)
      return false if ranks.empty? || ranks.max >= keys.size

      aggregate = BLS.aggregate_public_keys(ranks.map { |rank| point(keys[rank]) })
      signature = BLS::PointG2.from_hex(certificate["signature"])
      BLS.verify(signature, payload(certificate).unpack1("H*"), aggregate, scheme: :pop)
    rescue BLS::Error, BLS::PointError
      false
    end

    def payload(certificate)
      vote = SIGNED_VOTES.fetch(certificate["type"])
      block_id = vote == NOTAR_VOTE ? [certificate["block_id"]].pack("H*") : "".b
      [vote].pack("C") + [certificate["slot"]].pack("Q<") + block_id + [@shred_version].pack("S<")
    end

    def keys_for(epoch)
      @keys[epoch] ||= AlpenglowEpochRank.verifiable.where(network: @network, epoch: epoch).order(:rank).pluck(:bls_pubkey)
    end

    def point(bls_pubkey)
      @points[bls_pubkey] ||= BLS::PointG1.from_hex(Blockchain::Base58.decode(bls_pubkey).unpack1("H*"))
    end
  end
end
