# frozen_string_literal: true

require "test_helper"

module Blockchain
  class AlpenglowCertificateVerificationWorkerTest < ActiveSupport::TestCase
    setup do
      @network = "testnet"
      @certificates = [{ "type" => "fast", "slot" => 10 }]
      validator = create(:validator, network: @network, account: "IdentityA")
      vote_account = create(:vote_account, validator: validator, network: @network, account: "VoteA")
      AlpenglowEpochRank.create!(
        network: @network, epoch: 1, rank: 0, vote_account: "VoteA", validator_identity: "IdentityA",
        bls_pubkey: "blsA", stake: 100, status: :finalized
      )
      @stat = AlpenglowValidatorEpochStat.create!(
        network: @network, epoch: 1, vote_account: vote_account, validator: validator,
        notar_votes: 5, notar_reward_slots: 6, leader_slots: 3
      )
    end

    def result(type: "fast", valid: true, epoch: 1)
      { type: type, slot: 10, epoch: epoch, signers: 3, valid: valid }
    end

    def perform_with(results)
      verifier = Struct.new(:results) do
        def call(_certificates)
          results
        end
      end.new(results)
      errors = []

      Blockchain::EpochSchedule.stub(:fetch, nil) do
        Blockchain::AlpenglowCertificateVerifier.stub(:shred_version, 1) do
          Blockchain::AlpenglowCertificateVerifier.stub(:new, ->(**) { verifier }) do
            Appsignal.stub(:send_error, ->(error) { errors << error }) do
              worker = Blockchain::AlpenglowCertificateVerificationWorker.new
              worker.stub(:logger, Logger.new(nil)) { worker.perform(@network, @certificates) }
            end
          end
        end
      end
      errors
    end

    def rank_statuses
      AlpenglowEpochRank.where(network: @network, epoch: 1).pluck(:status).uniq
    end

    test "#perform marks ranks as verified when a finalization certificate is valid" do
      assert_empty perform_with([result, result(type: "notar_reward")])

      assert_equal ["verified"], rank_statuses
    end

    test "#perform does not verify ranks with only reward certificates" do
      perform_with([result(type: "notar_reward"), result(type: "skip_reward")])

      assert_equal ["finalized"], rank_statuses
    end

    test "#perform rejects ranks, resets voting stats and reports invalid certificates" do
      errors = perform_with([result(type: "notar_reward"), result(valid: false)])

      assert_equal ["rejected"], rank_statuses
      assert_equal [0, 0, 3], @stat.reload.values_at(:notar_votes, :notar_reward_slots, :leader_slots)
      assert_equal 1, errors.size
      assert_instance_of Blockchain::AlpenglowCertificateVerificationWorker::VerificationFailed, errors.first
      assert_includes errors.first.message, @network
    end

    test "#perform rejects previously verified ranks" do
      AlpenglowEpochRank.update_all(status: AlpenglowEpochRank.statuses[:verified])

      perform_with([result(valid: false)])

      assert_equal ["rejected"], rank_statuses
    end

    test "#perform does not verify rejected ranks again" do
      AlpenglowEpochRank.update_all(status: AlpenglowEpochRank.statuses[:rejected])

      perform_with([result])

      assert_equal ["rejected"], rank_statuses
    end

    test "#perform updates only the epoch of the checked certificates" do
      perform_with([result(epoch: 2)])

      assert_equal ["finalized"], rank_statuses
    end

    test "#perform does nothing when certificates could not be verified" do
      assert_empty perform_with([])
      assert_equal ["finalized"], rank_statuses
    end
  end
end
