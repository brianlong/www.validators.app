# frozen_string_literal: true

# == Schema Information
#
# Table name: alpenglow_epoch_ranks
#
#  id                 :bigint           not null, primary key
#  bls_pubkey         :string(191)      not null
#  epoch              :integer          not null
#  network            :string(191)      not null
#  rank               :integer          not null
#  stake              :bigint           not null
#  status             :integer          default("provisional"), not null
#  validator_identity :string(191)      not null
#  vote_account       :string(191)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_alpenglow_epoch_ranks_on_network_and_epoch_and_rank  (network,epoch,rank) UNIQUE
#  index_alpenglow_epoch_ranks_on_network_epoch_vote_account  (network,epoch,vote_account) UNIQUE
#
class AlpenglowEpochRank < ApplicationRecord
  enum status: { provisional: 0, finalized: 1, verified: 2, rejected: 3 }

  validates :network, inclusion: { in: NETWORKS }
  validates :epoch, :rank, :vote_account, :validator_identity, :bls_pubkey, :stake, presence: true

  scope :for_epoch, ->(network, epoch) { where(network: network, epoch: epoch).order(:rank) }
  scope :settled, -> { where.not(status: :provisional) }
  scope :verifiable, -> { where(status: %i[finalized verified]) }

  RETENTION = 30.days
  PRUNE_BATCH_SIZE = 10_000

  def self.mark_verified(network, epoch)
    where(network: network, epoch: epoch).finalized.update_all(status: statuses[:verified], updated_at: Time.current)
  end

  def self.mark_rejected(network, epoch)
    where(network: network, epoch: epoch).settled.update_all(status: statuses[:rejected], updated_at: Time.current)
  end

  def self.prune(before: RETENTION.ago)
    deleted = 0
    loop do
      ids = where("created_at < ?", before).limit(PRUNE_BATCH_SIZE).pluck(:id)
      break if ids.empty?

      deleted += where(id: ids).delete_all
    end
    deleted
  end
end
